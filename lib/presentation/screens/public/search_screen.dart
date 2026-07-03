import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/app_model.dart';
import '../../bloc/app_bloc.dart';
import '../../widgets/app_card.dart';
import '../../widgets/shimmer_loading.dart';
import 'app_detail_screen.dart';
import 'top_charts_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    if (query.isNotEmpty) {
      context.read<AppBloc>().add(LoadApps(searchQuery: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              ListTile(
                leading: const Icon(Icons.trending_up, color: AppColors.primary),
                title: const Text('Top Charts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TopChartsScreen()),
                  );
                },
              ),
              const Divider(),
            ],
            Expanded(
              child: _searchQuery.isEmpty
                  ? const _RecentSearches()
                  : BlocBuilder<AppBloc, AppState>(
                      builder: (context, state) {
                        if (state is AppLoading) {
                          return const ShimmerAppList();
                        }
                        if (state is AppsLoaded) {
                          if (state.apps.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                                  const SizedBox(height: 16),
                                  Text(l10n.noAppsFound, style: Theme.of(context).textTheme.titleLarge),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('Start typing to search apps', style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
