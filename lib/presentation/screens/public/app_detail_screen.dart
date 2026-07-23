import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/app_model.dart';
import '../../../data/models/review_model.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/download_bloc.dart';
import '../../widgets/review_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final app = widget.app;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with icon
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Hero(
                    tag: 'app_icon_${app.id}',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: app.iconUrl.isNotEmpty
                            ? Image.network(
                                app.iconUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.primary,
                                    child: const Icon(Icons.android, size: 50, color: Colors.white),
                                  );
                                },
                              )
                            : Container(
                                color: AppColors.primary,
                                child: const Icon(Icons.android, size: 50, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // App Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.name,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              app.developerName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
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

                  // Stats Row
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

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: BlocConsumer<DownloadBloc, DownloadState>(
                          listener: (context, state) {
                            if (state is DownloadCompleted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.downloadComplete)),
                              );
                            } else if (state is DownloadError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                              );
                            } else if (state is InstallSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('App installed successfully!')),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is DownloadInProgress) {
                              return Column(
                                children: [
                                  LinearProgressIndicator(value: state.progress),
                                  const SizedBox(height: 8),
                                  Text('${(state.progress * 100).toStringAsFixed(0)}%'),
                                ],
                              );
                            }
                            if (state is DownloadCompleted) {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  context.read<DownloadBloc>().add(
                                    InstallDownloadedApp(state.filePath),
                                  );
                                },
                                icon: const Icon(Icons.install_mobile),
                                label: Text(l10n.install),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              );
                            }
                            return ElevatedButton.icon(
                              onPressed: () {
                                context.read<DownloadBloc>().add(StartDownload(
                                  appId: app.id,
                                  url: app.apkUrl,
                                  fileName: '${app.packageName}_${app.version}.apk',
                                ));
                              },
                              icon: const Icon(Icons.download),
                              label: Text(l10n.install),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _showReportDialog(context),
                        icon: const Icon(Icons.flag_outlined),
                        tooltip: l10n.reportApp,
                      ),
                      IconButton(
                        onPressed: () {
                          // Share app
                        },
                        icon: const Icon(Icons.share_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Screenshots
                  if (app.screenshotUrls.isNotEmpty) ...[
                    Text(l10n.description, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 0.8,
                        enlargeCenterPage: true,
                      ),
                      items: app.screenshotUrls.map((url) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  Text(l10n.description, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  AnimatedCrossFade(
                    firstChild: Text(
                      app.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    secondChild: Text(
                      app.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  if (app.description.length > 100)
                    TextButton(
                      onPressed: () => setState(() => _isExpanded = !_isExpanded),
                      child: Text(_isExpanded ? 'Show Less' : 'Read More'),
                    ),
                  const SizedBox(height: 24),

                  // Tags
                  if (app.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: app.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Version Info
                  _InfoRow(label: 'Version', value: app.version),
                  _InfoRow(label: 'Package', value: app.packageName),
                  _InfoRow(label: 'Updated', value: Helpers.formatDate(app.updatedAt)),
                  const SizedBox(height: 24),

                  // Similar Apps
                  SimilarAppsSection(appId: app.id, category: app.category),
                  const SizedBox(height: 24),

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.reviews, style: Theme.of(context).textTheme.titleLarge),
                      TextButton(
                        onPressed: () => _showWriteReviewDialog(context),
                        child: Text(l10n.writeReview),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Reviews list would go here
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
        title: Text(l10n.reportApp),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: l10n.reportReason,
            hintText: 'Why are you reporting this app?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // Submit report
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.reportSubmitted)),
              );
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.writeReview),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) => rating = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Your review',
                hintText: 'Share your experience...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // Submit review
              Navigator.pop(context);
            },
            child: Text(l10n.submit),
          ),
        ],
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
