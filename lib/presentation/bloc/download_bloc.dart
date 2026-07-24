import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../core/theme/app_colors.dart';
import '../../../core/services/download_service.dart';
import '../../bloc/download_bloc.dart';
import 'package:devstore/l10n/app_localizations.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<File> _downloadedFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/devstore_downloads');

    if (!await downloadDir.exists()) {
      setState(() {
        _downloadedFiles = [];
        _isLoading = false;
      });
      return;
    }

    final files = await downloadDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.apk'))
        .map((entity) => entity as File)
        .toList();

    setState(() {
      _downloadedFiles = files;
      _isLoading = false;
    });
  }

  Future<void> _deleteFile(File file) async {
    try {
      await file.delete();
      await _loadDownloadedFiles();
    } catch (e) {
      // Ignore
    }
  }

  String _getFileName(String filePath) {
    return path.basename(filePath);
  }

  String _getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('My Downloads', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          if (_downloadedFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white70),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1A1A1A),
                    title: const Text('Clear All', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Delete all downloaded files?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete All'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  for (final file in _downloadedFiles) {
                    await file.delete();
                  }
                  await _loadDownloadedFiles();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white24))
          : _downloadedFiles.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_done, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text(
                        'No downloads yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Apps you download will appear here',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: const Color(0xFF1A1A1A),
                  onRefresh: _loadDownloadedFiles,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _downloadedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _downloadedFiles[index];
                      return _DownloadedFileCard(
                        fileName: _getFileName(file.path),
                        fileSize: _getFileSize(file),
                        filePath: file.path,
                        onInstall: () {
                          context.read<DownloadBloc>().add(InstallDownloadedApp(file.path));
                        },
                        onDelete: () => _deleteFile(file),
                      );
                    },
                  ),
                ),
    );
  }
}

class _DownloadedFileCard extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String filePath;
  final VoidCallback onInstall;
  final VoidCallback onDelete;

  const _DownloadedFileCard({
    required this.fileName,
    required this.fileSize,
    required this.filePath,
    required this.onInstall,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.android, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileSize,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BlocConsumer<DownloadBloc, DownloadState>(
                    listener: (context, state) {
                      if (state is InstallSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('App installed successfully!'),
                            backgroundColor: Colors.black,
                          ),
                        );
                      } else if (state is InstallError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is Installing) {
                        return const ElevatedButton(
                          onPressed: null,
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      return ElevatedButton.icon(
                        onPressed: onInstall,
                        icon: const Icon(Icons.install_mobile, size: 18),
                        label: const Text('Install'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
