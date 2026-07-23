import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/app_model.dart';
import '../../bloc/app_bloc.dart';
import '../../widgets/shimmer_loading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PendingApprovalsScreen extends StatelessWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pendingApprovals)),
      body: BlocProvider(
        create: (_) => AppBloc(context.read())..add(LoadPendingApps()),
        child: BlocConsumer<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
              );
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
            if (state is AppsLoaded) {
              final pendingApps = state.apps.where((a) => a.status == 'pending').toList();

              if (pendingApps.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 64, color: AppColors.success),
                      const SizedBox(height: 16),
                      Text('No pending approvals', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text('All apps have been reviewed', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingApps.length,
                itemBuilder: (context, index) {
                  final app = pendingApps[index];
                  return _PendingAppCard(app: app);
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

class _PendingAppCard extends StatelessWidget {
  final AppModel app;

  const _PendingAppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: app.iconUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(app.iconUrl, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.android, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(app.developerName, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('v${app.version} • ${app.category}', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(app.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AppBloc>().add(ApproveAppEvent(app.id));
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.approve),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context, app.id),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.reject),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
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

  void _showRejectDialog(BuildContext context, String appId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject App'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Why is this app being rejected?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppBloc>().add(RejectAppEvent(appId, reasonController.text));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
