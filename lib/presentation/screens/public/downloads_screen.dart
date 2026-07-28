import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/download_bloc.dart';
import '../public/app_detail_screen.dart';
import 'package:devstore/l10n/app_localizations.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
      ),
      body: BlocBuilder<DownloadBloc, DownloadState>(
        builder: (context, state) {
          if (state is! DownloadsMapState) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_done, size: 64, color: Colors.white70),
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
            );
          }

          // Get all downloads that are completed, installing, or installed
          final downloads = state.downloads.values.where((d) {
            return d.isCompleted || d.isInstalling || d.isInstalled || d.isDownloading;
          }).toList();

          if (downloads.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_done, size: 64, color: Colors.white70),
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final download = downloads[index];
              return _DownloadCard(
                download: download,
                onInstall: () {
                  if (download.filePath != null) {
                    context.read<DownloadBloc>().add(
                      InstallDownloadedApp(
                        appId: download.appId,
                        filePath: download.filePath!,
                      ),
                    );
                  }
                },
                onOpen: () {
                  // Open app - would need package name
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${download.appName}...')),
                  );
                },
                onCancel: () {
                  context.read<DownloadBloc>().add(
                    CancelDownload(appId: download.appId),
                  );
                },
                onDelete: () {
                  context.read<DownloadBloc>().add(
                    ResetDownload(appId: download.appId),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${download.appName} removed from downloads')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  final AppDownloadState download;
  final VoidCallback onInstall;
  final VoidCallback onOpen;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _DownloadCard({
    required this.download,
    required this.onInstall,
    required this.onOpen,
    required this.onCancel,
    required this.onDelete,
  });

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    Widget? actionButton;

    if (download.isDownloading) {
      statusText = 'Downloading... ${(download.progress * 100).toStringAsFixed(0)}%';
      statusColor = Colors.blue;
      actionButton = TextButton.icon(
        onPressed: onCancel,
        icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
        label: const Text('Cancel', style: TextStyle(color: Colors.red)),
      );
    } else if (download.isCompleted) {
      statusText = 'Downloaded';
      statusColor = Colors.green;
      actionButton = ElevatedButton.icon(
        onPressed: onInstall,
        icon: const Icon(Icons.install_mobile, size: 18),
        label: const Text('Install'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      );
    } else if (download.isInstalling) {
      statusText = 'Installing...';
      statusColor = Colors.orange;
      actionButton = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (download.isInstalled) {
      statusText = 'Installed';
      statusColor = AppColors.success;
      actionButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      );
    } else if (download.isError) {
      statusText = 'Error: ${download.errorMessage ?? 'Failed'}';
      statusColor = Colors.red;
      actionButton = TextButton(
        onPressed: onDelete,
        child: const Text('Remove', style: TextStyle(color: Colors.red)),
      );
    } else {
      statusText = 'Unknown';
      statusColor = Colors.grey;
      actionButton = null;
    }

    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: download.appIcon.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          download.appIcon,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.android, color: Colors.white),
                        ),
                      )
                    : const Icon(Icons.android, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.appName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                        ),
                      ),
                      if (download.isDownloading && download.totalBytes > 0)
                        Text(
                          '${_formatBytes(download.receivedBytes)} / ${_formatBytes(download.totalBytes)}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (download.isDownloading) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: download.progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 6,
                ),
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: actionButton,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
