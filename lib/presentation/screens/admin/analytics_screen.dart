import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/user_repository.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Analytics'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: UserRepository().getAnalytics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _StatCard(
                  title: 'Total Users',
                  value: data['totalUsers'].toString(),
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
                _StatCard(
                  title: 'Total Apps',
                  value: data['totalApps'].toString(),
                  icon: Icons.apps,
                  color: AppColors.secondary,
                ),
                _StatCard(
                  title: 'Total Developers',
                  value: data['totalDevelopers'].toString(),
                  icon: Icons.code,
                  color: AppColors.infoColor,
                ),
                _StatCard(
                  title: 'Total Downloads',
                  value: data['totalDownloads'].toString(),
                  icon: Icons.download,
                  color: AppColors.success,
                ),
                _StatCard(
                  title: 'Pending Approvals',
                  value: data['pendingApps'].toString(),
                  icon: Icons.pending,
                  color: AppColors.warning,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
