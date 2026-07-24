import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/app_model.dart';
import '../../bloc/app_bloc.dart';
import '../../widgets/shimmer_loading.dart';
import '../public/app_detail_screen.dart';

class AllAppsScreen extends StatelessWidget {
  const AllAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('All Apps'),
      ),
      body: BlocProvider(
        create: (_) => AppBloc(context.read())..add(const LoadApps()),
        child: BlocConsumer<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              // Refresh list after operation
              context.read<AppBloc>().add(const LoadApps());
            } else if (state is AppError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is AppLoading) {
              return const ShimmerAppList();
            }
            if (state is AppError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AppBloc>().add(const LoadApps());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is AppsLoaded) {
              if (state.apps.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apps, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text('No apps found', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.apps.length,
                itemBuilder: (context, index) {
                  final app = state.apps[index];
                  return _AdminAppCard(app: app);
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class _AdminAppCard extends StatelessWidget {
  final AppModel app;
  const _AdminAppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppDetailScreen(app: app),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // App icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: Colors.white12),
                ),
                child: app.iconUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          app.iconUrl,
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.android, color: AppColors.primary, size: 28);
                          },
                        ),
                      )
                    : const Icon(Icons.android, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              // App info
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
                      app.developerName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(app.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        app.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(app.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions menu
              PopupMenuButton<String>(
                iconColor: Colors.white,
                onSelected: (value) {
                  if (value == 'feature') {
                    context.read<AppBloc>().add(ToggleFeaturedEvent(app.id, !app.isFeatured));
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, app.id);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'feature',
                    child: Row(
                      children: [
                        Icon(
                          app.isFeatured ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          app.isFeatured ? 'Unfeature' : 'Feature',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(BuildContext context, String appId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete App', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppBloc>().add(DeleteAppEvent(appId));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
