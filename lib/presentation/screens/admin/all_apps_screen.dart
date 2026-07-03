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
      appBar: AppBar(title: const Text('All Apps')),
      body: BlocProvider(
        create: (_) => AppBloc(context.read())..add(const LoadApps()),
        child: BlocConsumer<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AppLoading) return const ShimmerAppList();
            if (state is AppsLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.apps.length,
                itemBuilder: (context, index) {
                  final app = state.apps[index];
                  return _AdminAppCard(app: app);
                },
              );
            }
            return const SizedBox.shrink();
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: app.iconUrl.isNotEmpty
              ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(app.iconUrl, fit: BoxFit.cover))
              : const Icon(Icons.android, color: AppColors.primary),
        ),
        title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${app.developerName} • ${app.status.toUpperCase()}'),
        trailing: PopupMenuButton<String>(
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
                  Icon(app.isFeatured ? Icons.star : Icons.star_border, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(app.isFeatured ? 'Unfeature' : 'Feature'),
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
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppDetailScreen(app: app))),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String appId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete App'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
