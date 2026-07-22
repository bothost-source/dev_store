import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storj_service.dart';
import '../../../data/models/app_model.dart';
import '../../bloc/auth_bloc.dart';
import 'package:devstore/l10n/app_localizations.dart';
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
  bool _uploadSuccess = false;

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
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['apk']);
    if (result != null) setState(() => _apkFile = File(result.files.single.path!));
  }

  Future<void> _pickIcon() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _iconFile = File(image.path));
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
    _showSnackBar('Please select an APK file');
    return;
  }
  if (_iconFile == null) {
    _showSnackBar('Please select an app icon');
    return;
  }

  final apkSize = await _apkFile!.length();
  if (apkSize > AppConstants.maxApkSize) {
    _showSnackBar('APK file is too large (max 500MB)');
    return;
  }
    
    setState(() => _isUploading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) throw Exception('You must be logged in');

      final developerId = authState.user.uid;
      final developerName = authState.user.displayName;
      final appId = DateTime.now().millisecondsSinceEpoch.toString();

      final bucket = await _storjService.getAvailableBucket();

      setState(() => _uploadProgress = 0.1);
      final apkPath = await _storjService.uploadFile(
        file: _apkFile!,
        folder: '${AppConstants.pendingFolder}/$appId',
        fileName: 'app.apk',
        specificBucket: bucket,
      );

      setState(() => _uploadProgress = 0.3);
      final iconPath = await _storjService.uploadFile(
        file: _iconFile!,
        folder: '${AppConstants.pendingFolder}/$appId',
        fileName: 'icon.png',
        specificBucket: bucket,
      );

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

      final tags = _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

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

      setState(() {
        _uploadProgress = 1.0;
        _uploadSuccess = true;
      });
    } catch (e) {
      if (mounted) _showSnackBar('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFF1A1A1A)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // SUCCESS SCREEN
    if (_uploadSuccess) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text('Upload Successful!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              const Text(
                'Your app has been submitted for review.\nYou will be notified once it is approved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.uploadApp, style: const TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          if (!_isUploading)
            TextButton(
              onPressed: _uploadApp,
              child: Text(l10n.submit, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      backgroundColor: const Color(0xFF1A1A1A),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 8),
                  const Text('Please do not close the app', style: TextStyle(color: Colors.white70)),
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
                    _FilePickerCard(title: 'APK File', subtitle: _apkFile != null ? _apkFile!.path.split('/').last : 'Tap to select APK', icon: Icons.android, isSelected: _apkFile != null, onTap: _pickApk),
                    const SizedBox(height: 16),
                    _FilePickerCard(
                      title: 'App Icon',
                      subtitle: _iconFile != null ? 'Icon selected' : 'Tap to select icon',
                      icon: Icons.image,
                      isSelected: _iconFile != null,
                      onTap: _pickIcon,
                      preview: _iconFile != null ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_iconFile!, width: 60, height: 60, fit: BoxFit.cover)) : null,
                    ),
                    const SizedBox(height: 16),
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
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 8, top: 8),
                            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_screenshots[index], width: 80, height: 80, fit: BoxFit.cover)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildField('App Name', _nameController, Icons.app_shortcut),
                    const SizedBox(height: 16),
                    _buildField('Package Name (e.g., com.example.app)', _packageNameController, Icons.code),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Category', Icons.category),
                      items: AppConstants.appCategories.where((c) => c != 'All').map((category) => DropdownMenuItem(value: category, child: Text(category, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Description', Icons.description),
                      maxLines: 5,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField('Version', _versionController, Icons.numbers),
                    const SizedBox(height: 16),
                    _buildField('Minimum Android Version', _minAndroidController, Icons.android),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Tags (comma separated)', Icons.tag, hint: 'game, action, free'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
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

  const _FilePickerCard({required this.title, required this.subtitle, required this.icon, required this.isSelected, required this.onTap, this.preview});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.white : Colors.white24, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: isSelected ? Colors.white : const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: isSelected ? Colors.black : Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (preview != null) preview!,
            Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline, color: isSelected ? Colors.white : Colors.white70),
          ],
        ),
      ),
    );
  }
}
