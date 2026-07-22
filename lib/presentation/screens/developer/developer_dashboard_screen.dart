import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/app_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../widgets/app_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../public/app_detail_screen.dart';
import 'upload_app_screen.dart';
import 'package:devstore/l10n/app_localizations.dart';

class DeveloperDashboardScreen extends StatelessWidget {
  const DeveloperDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthBloc>().state;
    final developerId = authState is Authenticated ? authState.user.uid : '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.developer),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UploadAppScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) => AppBloc(context.read<AppRepository>())..add(LoadDeveloperApps(developerId)),
        child: CustomScrollView(
          slivers: [
            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    if (state is AppsLoaded) {
                      final apps = state.apps;
                      final totalDownloads = apps.fold<int>(0, (sum, app) => sum + app.downloadCount);
                      final approvedApps = apps.where((a) => a.status == 'approved').length;
                      final pendingApps = apps.where((a) => a.status == 'pending').length;

                      return Row(
                        children: [
                          _StatCard(
                            title: 'My Apps',
                            value: apps.length.toString(),
                            icon: Icons.apps,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            title: 'Downloads',
                            value: totalDownloads.toString(),
                            icon: Icons.download,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            title: 'Pending',
                            value: pendingApps.toString(),
                            icon: Icons.hourglass_empty,
                          ),
                        ],
                      );
                    }
                    return const Row(
                      children: [
                        Expanded(child: _StatCardSkeleton()),
                        SizedBox(width: 12),
                        Expanded(child: _StatCardSkeleton()),
                        SizedBox(width: 12),
                        Expanded(child: _StatCardSkeleton()),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  l10n.myApps,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Apps List
            BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                if (state is AppLoading) {
                  return const SliverToBoxAdapter(child: ShimmerAppList());
                }
                if (state is AppError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                if (state is AppsLoaded) {
                  if (state.apps.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            const Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.white70),
                            const SizedBox(height: 16),
                            const Text(
                              'No apps yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Upload your first app to get started',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const UploadAppScreen()),
                                );
                              },
                              icon: const Icon(Icons.add, color: Colors.black),
                              label: Text(l10n.uploadApp, style: const TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final app = state.apps[index];
                        return _DeveloperAppCard(app: app);
                      },
                      childCount: state.apps.length,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.apps, color: Colors.white, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
    );
  }
}

class _DeveloperAppCard extends StatelessWidget {
  final AppModel app;

  const _DeveloperAppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111111),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white24),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AppDetailScreen(app: app)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(color: Colors.white24),
                ),
                child: app.iconUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(app.iconUrl, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.android, color: Colors.white),
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
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v${app.version}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          app.status == 'approved' ? Icons.check_circle :
                          app.status == 'pending' ? Icons.hourglass_empty :
                          Icons.cancel,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          app.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    app.downloadCount.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'downloads',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
