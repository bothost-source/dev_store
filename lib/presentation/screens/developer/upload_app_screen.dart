import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storj_service.dart';
import '../../../data/models/app_model.dart';
import '../../bloc/auth_bloc.dart';
import '../public/main_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadAppScreen extends StatefulWidget {
  const UploadAppScreen({super.key});

  @override
  State<UploadAppScreen> createState() => _UploadAppScreenState();
}

class _UploadAppScreenState extends State<UploadAppScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _packageNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0.0');
  final _minAndroidController = TextEditingController(text: '5.0');
  final _tagsController = TextEditingController();

  String _selectedCategory = AppConstants.appCategories[1];
  File? _apkFile;
  File? _iconFile;
  List<File> _screenshots = [];
  bool _isUploading = false;
  double _uploadProgress = 0;

  final StorjService _storjService = StorjService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _packageNameController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    _minAndroidController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickApk() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );
    if (result != null) {
      setState(() => _apkFile = File(result.files.single.path!));
    }
  }

  Future<void> _pickIcon() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _iconFile = File(image.path));
    }
  }

  Future<void> _pickScreenshots() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _screenshots = images.map((i) => File(i.path)).toList();
        if (_screenshots.length > AppConstants.maxScreenshots) {
          _screenshots = _screenshots.sublist(0, AppConstants.maxScreenshots);
        }
      });
    }
  }

  Future<void> _uploadApp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_apkFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an APK file')),
      );
      return;
    }
    if (_iconFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an app icon')),
      );
      return;
    }

    final apkSize = await _apkFile!.length();
    if (apkSize > AppConstants.maxApkSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('APK file is too large (max 500MB)')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw Exception('You must be logged in');
      }

      final developerId = authState.user.uid;
      final developerName = authState.user.displayName;
      final appId = DateTime.now().millisecondsSinceEpoch.toString();

      // Get available bucket
      final bucket = await _storjService.getAvailableBucket();

      // Upload APK
      setState(() => _uploadProgress = 0.1);
      final apkPath = await _storjService.uploadFile(
        file: _apkFile!,
        folder: '${AppConstants.pendingFolder}/$appId',
        fileName: 'app.apk',
        specificBucket: bucket,
      );

      // Upload Icon
      setState(() => _uploadProgress = 0.3);
      final iconPath = await _storjService.uploadFile(
        file: _iconFile!,
        folder: '${AppConstants.pendingFolder}/$appId',
        fileName: 'icon.png',
        specificBucket: bucket,
      );

      // Upload Screenshots
      final screenshotUrls = <String>[];
      for (var i = 0; i < _screenshots.length; i++) {
        setState(() => _uploadProgress = 0.3 + (0.4 * (i / _screenshots.length)));
        final ssPath = await _storjService.uploadFile(
          file: _screenshots[i],
          folder: '${AppConstants.pendingFolder}/$appId/screenshots',
          fileName: 'ss_$i.jpg',
          specificBucket: bucket,
        );
        final parts = ssPath.split('/');
        screenshotUrls.add(_storjService.getPublicUrl(parts[0], parts.sublist(1).join('/')));
      }

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // Create app document
      setState(() => _uploadProgress = 0.9);
      final app = AppModel(
        id: appId,
        name: _nameController.text.trim(),
        packageName: _packageNameController.text.trim(),
        description: _descriptionController.text.trim(),
        developerId: developerId,
        developerName: developerName,
        category: _selectedCategory,
        tags: tags,
        version: _versionController.text.trim(),
        minAndroidVersion: _minAndroidController.text.trim(),
        apkSize: apkSize,
        iconUrl: _storjService.getPublicUrl(bucket, '${AppConstants.pendingFolder}/$appId/icon.png'),
        screenshotUrls: screenshotUrls,
        apkUrl: _storjService.getPublicUrl(bucket, '${AppConstants.pendingFolder}/$appId/app.apk'),
        status: AppConstants.statusPending,
        bucket: bucket,
        storagePath: apkPath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection(AppConstants.appsCollection).doc(appId).set(app.toFirestore());

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.appUploaded),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uploadApp),
        actions: [
          if (!_isUploading)
            TextButton(
              onPressed: _uploadApp,
              child: Text(l10n.submit, style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Please do not close the app', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // APK File
                    _FilePickerCard(
                      title: 'APK File',
                      subtitle: _apkFile != null ? _apkFile!.path.split('/').last : 'Tap to select APK',
                      icon: Icons.android,
                      isSelected: _apkFile != null,
                      onTap: _pickApk,
                    ),
                    const SizedBox(height: 16),

                    // Icon
                    _FilePickerCard(
                      title: 'App Icon',
                      subtitle: _iconFile != null ? 'Icon selected' : 'Tap to select icon',
                      icon: Icons.image,
                      isSelected: _iconFile != null,
                      onTap: _pickIcon,
                      preview: _iconFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_iconFile!, width: 60, height: 60, fit: BoxFit.cover),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Screenshots
                    _FilePickerCard(
                      title: 'Screenshots (${_screenshots.length}/${AppConstants.maxScreenshots})',
                      subtitle: _screenshots.isNotEmpty ? '${_screenshots.length} selected' : 'Tap to select screenshots',
                      icon: Icons.photo_library,
                      isSelected: _screenshots.isNotEmpty,
                      onTap: _pickScreenshots,
                    ),
                    if (_screenshots.isNotEmpty)
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _screenshots.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8, top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_screenshots[index], width: 80, height: 80, fit: BoxFit.cover),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),

                    // App Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'App Name',
                        prefixIcon: Icon(Icons.app_shortcut),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Package Name
                    TextFormField(
                      controller: _packageNameController,
                      decoration: const InputDecoration(
                        labelText: 'Package Name (e.g., com.example.app)',
                        prefixIcon: Icon(Icons.code),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppConstants.appCategories
                          .where((c) => c != 'All')
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Version
                    TextFormField(
                      controller: _versionController,
                      decoration: const InputDecoration(
                        labelText: 'Version',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Min Android Version
                    TextFormField(
                      controller: _minAndroidController,
                      decoration: const InputDecoration(
                        labelText: 'Minimum Android Version',
                        prefixIcon: Icon(Icons.android),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        prefixIcon: Icon(Icons.tag),
                        hintText: 'game, action, free',
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

class _FilePickerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? preview;

  const _FilePickerCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.success.withOpacity(0.1) : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.success : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (preview != null) preview!,
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.success)
            else
              const Icon(Icons.add_circle_outline, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
