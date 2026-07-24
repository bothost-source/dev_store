import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/app_model.dart';

class AppCard extends StatelessWidget {
  final AppModel app;
  final VoidCallback onTap;
  final bool compact;

  const AppCard({
    super.key,
    required this.app,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactCard(app: app, onTap: onTap);
    }
    return _FullCard(app: app, onTap: onTap);
  }
}

class _FullCard extends StatelessWidget {
  final AppModel app;
  final VoidCallback onTap;

  const _FullCard({required this.app, required this.onTap});

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'app_icon_${app.id}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: app.iconUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            app.iconUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.android, color: AppColors.primary);
                            },
                          ),
                        )
                      : const Icon(Icons.android, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.developerName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          app.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          Helpers.formatNumber(app.downloadCount),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'downloads',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Helpers.formatFileSize(app.apkSize),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  final AppModel app;
  final VoidCallback onTap;

  const _CompactCard({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: app.iconUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      app.iconUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.android, color: AppColors.primary);
                      },
                    ),
                  )
                : const Icon(Icons.android, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            app.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            app.developerName,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                app.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
