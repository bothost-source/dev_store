import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/app_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../bloc/app_bloc.dart';
import '../../widgets/app_card.dart';
import '../../widgets/shimmer_loading.dart';
import 'app_detail_screen.dart';

class CategoryAppsScreen extends StatelessWidget {
  final String category;

  const CategoryAppsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(category, style: const TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) => AppBloc(context.read<AppRepository>())..add(LoadApps(category: category)),
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is AppLoading) {
              return const ShimmerAppList();
            }
            if (state is AppError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            if (state is AppsLoaded) {
              if (state.apps.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: Colors.white70),
                      SizedBox(height: 16),
                      Text(
                        'No apps in this category yet',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.apps.length,
                itemBuilder: (context, index) {
                  final app = state.apps[index];
                  return AppCard(
                    app: app,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AppDetailScreen(app: app)),
                      );
                    },
                  );
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
