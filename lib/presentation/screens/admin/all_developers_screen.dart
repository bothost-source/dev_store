import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class AllDevelopersScreen extends StatelessWidget {
  const AllDevelopersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Developers')),
      body: StreamBuilder<List<UserModel>>(
        stream: UserRepository().getDevelopers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final developers = snapshot.data!;
          if (developers.isEmpty) {
            return const Center(child: Text('No developers yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: developers.length,
            itemBuilder: (context, index) {
              final dev = developers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(dev.displayName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary)),
                  ),
                  title: Text(dev.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(dev.email),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('View Apps'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
