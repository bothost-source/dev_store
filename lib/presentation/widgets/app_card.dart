import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/app_model.dart';

class AppCard extends StatelessWidget {
  final AppModel app;
  final VoidCallback onTap;
  final bool compact;
  final bool showInstallButton;
  final VoidCallback? onInstall;

  const AppCard({
    super.key,
    required this.app,
    required this.onTap,
    this.compact = false,
    this.showInstallButton = false,
    this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactCard(
        app: app,
        onTap: onTap,
        showInstallButton: showInstallButton,
        onInstall: onInstall,
      );
    }
    return _FullCard(
      app: app,
      onTap: onTap,
      showInstallButton: showInstallButton,
      onInstall: onInstall,
    );
  }
}

// ─────────────────────────────────────────────
// FULL CARD (List View Style)
// ─────────────────────────────────────────────

class _FullCard extends StatelessWidget {
  final AppModel app;
  final VoidCallback onTap;
  final bool showInstallButton;
  final VoidCallback? onInstall;

  const _FullCard({
    required this.app,
    required this.onTap,
    this.showInstallButton = false,
    this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Icon with Hero + CachedNetworkImage
              Hero(
                tag: 'app_icon_${app.id}',
                child: _AppIcon(
                  iconUrl: app.iconUrl,
                  size: 72,
                  borderRadius: 20,
                ),
              ),
              const SizedBox(width: 16),

              // App Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Name
                    Text(
                      app.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Developer Name
                    Text(
                      app.developerName,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : AppColors.textMuted,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Stats Row
                    Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Rating
                        _StatBadge(
                          icon: Icons.star_rounded,
                          iconColor: Colors.amber,
                          value: app.averageRating.toStringAsFixed(1),
                        ),

                        // Downloads
                        _StatBadge(
                          icon: Icons.download_rounded,
                          iconColor: isDark ? Colors.white54 : Colors.black45,
                          value: Helpers.formatNumber(app.downloadCount),
                        ),

                        // File Size
                        _StatBadge(
                          icon: Icons.storage_outlined,
                          iconColor: isDark ? Colors.white54 : Colors.black45,
                          value: Helpers.formatFileSize(app.apkSize),
                        ),
                      ],
                    ),

                    // Category Chip (if available)
                    if (app.category != null && app.category!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          app.category!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Install Button (optional)
              if (showInstallButton && onInstall != null) ...[
                const SizedBox(width: 8),
                _InstallButton(onTap: onInstall!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMPACT CARD (Grid View Style)
// ─────────────────────────────────────────────

class _CompactCard extends StatelessWidget {
  final AppModel app;
  final VoidCallback onTap;
  final bool showInstallButton;
  final VoidCallback? onInstall;

  const _CompactCard({
    required this.app,
    required this.onTap,
    this.showInstallButton = false,
    this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : AppColors.primary.withOpacity(0.08),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _AppIcon(
                    iconUrl: app.iconUrl,
                    size: 110,
                    borderRadius: 20,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Install button overlay (optional)
              if (showInstallButton && onInstall != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: _MiniInstallButton(onTap: onInstall!),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // App Name
          Text(
            app.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Developer
          Text(
            app.developerName,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white50 : AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Rating + Downloads Row
          Row(
            children: [
              // Rating
              Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade600),
              const SizedBox(width: 3),
              Text(
                app.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),

              // Downloads
              Icon(
                Icons.download_rounded,
                size: 13,
                color: isDark ? Colors.white40 : Colors.black38,
              ),
              const SizedBox(width: 2),
              Text(
                Helpers.formatNumber(app.downloadCount),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white40 : Colors.black45,
                ),
              ),

              const Spacer(),

              // File size
              Text(
                Helpers.formatFileSize(app.apkSize),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

class _AppIcon extends StatelessWidget {
  final String iconUrl;
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const _AppIcon({
    required this.iconUrl,
    required this.size,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (iconUrl.isEmpty) {
      return _PlaceholderIcon(size: size, borderRadius: borderRadius);
    }

    return CachedNetworkImage(
      imageUrl: iconUrl,
      width: size,
      height: size,
      fit: fit,
      placeholder: (context, url) => _ShimmerIcon(size: size, borderRadius: borderRadius),
      errorWidget: (context, url, error) => _PlaceholderIcon(size: size, borderRadius: borderRadius),
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      ),
    );
  }
}

class _ShimmerIcon extends StatelessWidget {
  final double size;
  final double borderRadius;

  const _ShimmerIcon({required this.size, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  final double size;
  final double borderRadius;

  const _PlaceholderIcon({required this.size, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.android_rounded,
        size: size * 0.4,
        color: isDark ? Colors.white30 : AppColors.primary.withOpacity(0.5),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _InstallButton extends StatelessWidget {
  final VoidCallback onTap;

  const _InstallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text(
            'Install',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniInstallButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MiniInstallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.download_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
