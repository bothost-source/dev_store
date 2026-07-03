import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/app_model.dart';
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
      appBar: AppBar(title: Text(category)),
      body: BlocProvider(
        create: (_) => AppBloc(context.read())..add(LoadApps(category: category)),
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is AppLoading) {
              return const ShimmerAppList();
            }
            if (state is AppsLoaded) {
              if (state.apps.isEmpty) {
                return const Center(child: Text('No apps in this category yet'));
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
