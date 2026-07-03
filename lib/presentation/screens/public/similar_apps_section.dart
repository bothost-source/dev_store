import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/app_model.dart';
import '../../bloc/app_bloc.dart';
import '../../widgets/app_card.dart';
import 'app_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SimilarAppsSection extends StatelessWidget {
  final String appId;
  final String category;

  const SimilarAppsSection({super.key, required this.appId, required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => AppBloc(context.read())..add(LoadSimilarApps(appId, category)),
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AppDetailLoaded && state.similarApps.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.similarApps, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.similarApps.length,
                    itemBuilder: (context, index) {
                      final app = state.similarApps[index];
                      return SizedBox(
                        width: 140,
                        child: AppCard(
                          app: app,
                          compact: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => AppDetailScreen(app: app)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
