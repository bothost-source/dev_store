import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/app_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../bloc/download_bloc.dart';
import 'similar_apps_section.dart';
import 'package:devstore/l10n/app_localizations.dart';

class AppDetailScreen extends StatefulWidget {
  final AppModel app;

  const AppDetailScreen({super.key, required this.app});

  @override
  State<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends State<AppDetailScreen> {
  bool _isExpanded = false;

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
    final app = widget.app;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            expandedHeight: 0,
            toolbarHeight: 80,
            title: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: app.iconUrl.isNotEmpty
                      ? Image.network(
                          app.iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.android, size: 24, color: Colors.white),
                        )
                      : const Icon(Icons.android, size: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        app.developerName,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          app.category,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.star,
                        value: app.averageRating.toStringAsFixed(1),
                        label: l10n.rating,
                        color: Colors.amber,
                      ),
                      _StatItem(
                        icon: Icons.download,
                        value: Helpers.formatNumber(app.downloadCount),
                        label: l10n.downloads,
                        color: AppColors.secondary,
                      ),
                      _StatItem(
                        icon: Icons.storage,
                        value: Helpers.formatFileSize(app.apkSize),
                        label: l10n.appSize,
                        color: AppColors.infoColor,
                      ),
                      _StatItem(
                        icon: Icons.android,
                        value: app.minAndroidVersion,
                        label: l10n.requiresAndroid,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Download / Install Button Section
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: BlocConsumer<DownloadBloc, DownloadState>(
                          listener: (context, state) {
                            if (state is DownloadCompleted && state.appId == app.id) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Download complete! Tap Install to continue.'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            } else if (state is DownloadError && state.appId == app.id) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${state.message}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else if (state is InstallSuccess && state.appId == app.id) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Installed successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else if (state is InstallError && state.appId == app.id) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Install failed: ${state.message}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            // Check if this app's download state
                            final isThisAppDownloading = state is DownloadInProgress && state.appId == app.id;
                            final isCompleted = state is DownloadCompleted && state.appId == app.id;
                            final isInstalling = state is Installing && state.appId == app.id;
                            final isInstallSuccess = state is InstallSuccess && state.appId == app.id;

                            // Downloading in progress - OLD STYLE from your screenshot
                            if (isThisAppDownloading) {
                              final percent = (state.progress * 100).toStringAsFixed(0);
                              final receivedStr = _formatBytes(state.receivedBytes);
                              final totalStr = _formatBytes(state.totalBytes);

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Green progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: state.progress,
                                        backgroundColor: Colors.white24,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Percentage text
                                    Text(
                                      'Downloading... $percent%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Actual bytes / total bytes
                                    Text(
                                      '$receivedStr / $totalStr',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Cancel button
                                    TextButton.icon(
                                      onPressed: () {
                                        context.read<DownloadBloc>().add(
                                          CancelDownload(appId: app.id),
                                        );
                                      },
                                      icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                                      label: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.red, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Download completed - show Install button
                            if (isCompleted) {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  context.read<DownloadBloc>().add(
                                    InstallDownloadedApp(
                                      appId: app.id,
                                      filePath: state.filePath,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.install_mobile, color: Colors.white),
                                label: const Text(
                                  'Install Now',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }

                            // Installing
                            if (isInstalling) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.green,
                                      strokeWidth: 2,
                                    ),
                                    SizedBox(width: 12),
                                    Text('Installing...', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              );
                            }

                            // Install success - show done
                            if (isInstallSuccess) {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  context.read<DownloadBloc>().add(
                                    ResetDownload(appId: app.id),
                                  );
                                },
                                icon: const Icon(Icons.check_circle, color: Colors.white),
                                label: const Text(
                                  'Installed',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }

                            // Default: Download button (VISIBLE - not white on white)
                            return ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Starting download...'),
                                    duration: Duration(milliseconds: 800),
                                    backgroundColor: Colors.black,
                                  ),
                                );
                                context.read<DownloadBloc>().add(StartDownload(
                                  appId: app.id,
                                  url: app.apkUrl,
                                  fileName: '${app.packageName}_${app.version}.apk',
                                ));
                              },
                              icon: const Icon(Icons.download, color: Colors.white),
                              label: const Text(
                                'Download & Install',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showReportDialog(context),
                        icon: const Icon(Icons.flag_outlined, color: Colors.white70),
                        tooltip: l10n.reportApp,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (app.screenshotUrls.isNotEmpty) ...[
                    Text(
                      'Screenshots',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 400,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: app.screenshotUrls.length,
                        itemBuilder: (context, index) {
                          final url = app.screenshotUrls[index];
                          return Container(
                            margin: EdgeInsets.only(
                              right: index < app.screenshotUrls.length - 1 ? 12 : 0,
                            ),
                            width: MediaQuery.of(context).size.width * 0.7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFF1A1A1A),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: const Color(0xFF1A1A1A),
                                    child: const Center(
                                      child: CircularProgressIndicator(color: Colors.white24),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFF1A1A1A),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, color: Colors.white24, size: 48),
                                        SizedBox(height: 8),
                                        Text('Image failed to load', style: TextStyle(color: Colors.white38)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    l10n.description,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedCrossFade(
                    firstChild: Text(
                      app.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, height: 1.5),
                    ),
                    secondChild: Text(
                      app.description,
                      style: const TextStyle(color: Colors.white70, height: 1.5),
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  if (app.description.length > 100)
                    TextButton(
                      onPressed: () => setState(() => _isExpanded = !_isExpanded),
                      child: Text(
                        _isExpanded ? 'Show Less' : 'Read More',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 24),

                  if (app.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: app.tags.map((tag) {
                        return Chip(
                          label: Text(tag, style: const TextStyle(color: Colors.white)),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  _InfoRow(label: 'Version', value: app.version),
                  _InfoRow(label: 'Package', value: app.packageName),
                  _InfoRow(label: 'Updated', value: Helpers.formatDate(app.updatedAt)),
                  const SizedBox(height: 24),

                  SimilarAppsSection(appId: app.id, category: app.category),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.reviews,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showWriteReviewDialog(context),
                        child: Text(
                          l10n.writeReview,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(l10n.reportApp, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.reportReason,
            hintText: 'Why are you reporting this app?',
            labelStyle: const TextStyle(color: Colors.white70),
            hintStyle: const TextStyle(color: Colors.white38),
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a reason'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              try {
                await context.read<AppRepository>().reportApp(
                  appId: widget.app.id,
                  appName: widget.app.name,
                  reason: reason,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.reportSubmitted),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to submit report: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double currentRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(l10n.writeReview, style: const TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: 5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 32,
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (value) {
                    setDialogState(() {
                      currentRating = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Your review',
                    hintText: 'Share your experience...',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintStyle: TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () {
                  debugPrint('Rating: $currentRating, Comment: ${commentController.text}');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review submitted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text(l10n.submit),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
