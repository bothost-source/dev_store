import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/user_repository.dart';
import 'pending_approvals_screen.dart';
import 'all_apps_screen.dart';
import 'all_developers_screen.dart';
import 'reports_screen.dart';
import 'analytics_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminPanel),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: UserRepository().getAnalytics(),
        builder: (context, snapshot) {
          final analytics = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Analytics Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _AnalyticsCard(
                      title: l10n.totalApps,
                      value: (analytics['totalApps'] ?? 0).toString(),
                      icon: Icons.apps,
                      color: AppColors.primary,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllAppsScreen())),
                    ),
                    _AnalyticsCard(
                      title: l10n.totalDownloads,
                      value: (analytics['totalDownloads'] ?? 0).toString(),
                      icon: Icons.download,
                      color: AppColors.secondary,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                    ),
                    _AnalyticsCard(
                      title: l10n.totalDevelopers,
                      value: (analytics['totalDevelopers'] ?? 0).toString(),
                      icon: Icons.code,
                      color: AppColors.infoColor,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllDevelopersScreen())),
                    ),
                    _AnalyticsCard(
                      title: l10n.pendingApprovals,
                      value: (analytics['pendingApps'] ?? 0).toString(),
                      icon: Icons.hourglass_empty,
                      color: AppColors.warning,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingApprovalsScreen())),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _ActionTile(
                  icon: Icons.pending_actions,
                  title: l10n.pendingApprovals,
                  subtitle: 'Review and approve submitted apps',
                  color: AppColors.warning,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingApprovalsScreen())),
                ),
                _ActionTile(
                  icon: Icons.apps,
                  title: l10n.allApps,
                  subtitle: 'Manage all apps in the store',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllAppsScreen())),
                ),
                _ActionTile(
                  icon: Icons.people,
                  title: l10n.allDevelopers,
                  subtitle: 'View and manage developers',
                  color: AppColors.infoColor,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllDevelopersScreen())),
                ),
                _ActionTile(
                  icon: Icons.flag,
                  title: l10n.reports,
                  subtitle: 'Handle user reports',
                  color: AppColors.error,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                ),
                _ActionTile(
                  icon: Icons.analytics,
                  title: l10n.analytics,
                  subtitle: 'View detailed statistics',
                  color: AppColors.secondary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
