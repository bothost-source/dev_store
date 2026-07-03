import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/app_model.dart';
import '../../bloc/app_bloc.dart';
import '../../widgets/app_card.dart';
import '../../widgets/shimmer_loading.dart';
import 'app_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TopChartsScreen extends StatelessWidget {
  const TopChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.topCharts)),
      body: BlocProvider(
        create: (_) => AppBloc(context.read())..add(LoadTopCharts()),
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is AppLoading) {
              return const ShimmerAppList();
            }
            if (state is AppsLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.apps.length,
                itemBuilder: (context, index) {
                  final app = state.apps[index];
                  return Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: index < 3 ? Colors.amber : null,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: AppCard(
                          app: app,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => AppDetailScreen(app: app)),
                            );
                          },
                        ),
                      ),
                    ],
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
