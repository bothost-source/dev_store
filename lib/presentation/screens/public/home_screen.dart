import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/app_model.dart';
import '../../bloc/app_bloc.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';
import 'app_detail_screen.dart';
import 'category_apps_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppBloc(context.read())..add(LoadFeaturedApps())),
        BlocProvider(create: (_) => AppBloc(context.read())..add(LoadNewReleases())),
      ],
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(l10n.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                ),
              ),
            ),

            // Featured Apps Section
            SliverToBoxAdapter(
              child: BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  if (state is AppLoading) {
                    return const ShimmerFeaturedSection();
                  }
                  if (state is AppsLoaded) {
                    return _buildFeaturedSection(context, state.apps);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Categories Section
            SliverToBoxAdapter(
              child: _buildCategoriesSection(context),
            ),

            // New Releases Section
            SliverToBoxAdapter(
              child: BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  if (state is AppLoading) {
                    return const ShimmerAppList();
                  }
                  if (state is AppsLoaded) {
                    return _buildNewReleasesSection(context, state.apps);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, List<AppModel> apps) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       SectionHeader(title: 'Featured', onSeeAll: () {}),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return _FeaturedAppCard(app: app);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.categories, onSeeAll: () {}),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppConstants.appCategories.length - 1, // Skip "All"
            itemBuilder: (context, index) {
              final category = AppConstants.appCategories[index + 1];
              return _CategoryChip(
                category: category,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryAppsScreen(category: category),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewReleasesSection(BuildContext context, List<AppModel> apps) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.newReleases, onSeeAll: () {}),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            return AppCard(
              app: app,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AppDetailScreen(app: app)),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _FeaturedAppCard extends StatelessWidget {
  final AppModel app;

  const _FeaturedAppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AppDetailScreen(app: app)),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppColors.accentGradient,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: app.iconUrl.isNotEmpty
                    ? Image.network(app.iconUrl, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.3))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.developerName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        app.averageRating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Helpers.formatNumber(app.downloadCount),
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'downloads',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const _CategoryChip({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Helpers.getCategoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Games': Icons.games,
      'Productivity': Icons.work_outline,
      'Social': Icons.people_outline,
      'Entertainment': Icons.movie_outlined,
      'Education': Icons.school_outlined,
      'Finance': Icons.account_balance_wallet_outlined,
      'Health & Fitness': Icons.fitness_center,
      'Music & Audio': Icons.music_note,
      'Photography': Icons.camera_alt_outlined,
      'Shopping': Icons.shopping_bag_outlined,
      'Tools': Icons.build_outlined,
      'Travel': Icons.flight_takeoff,
      'Communication': Icons.chat_bubble_outline,
      'News & Magazines': Icons.newspaper,
    };
    return icons[category] ?? Icons.apps;
  }
}
