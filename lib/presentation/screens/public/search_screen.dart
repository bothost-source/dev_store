import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/app_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../bloc/app_bloc.dart';
import '../../widgets/app_card.dart';
import '../../widgets/shimmer_loading.dart';
import 'app_detail_screen.dart';
import 'top_charts_screen.dart';
import 'package:devstore/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _recentSearches = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => _recentSearches = []);
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    setState(() => _searchQuery = query);

    if (query.isEmpty) return;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _saveRecentSearch(query);
      context.read<AppBloc>().add(LoadApps(searchQuery: query));
    });
  }

  void _onRecentTap(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    _onSearchChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => AppBloc(context.read<AppRepository>()),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
              ),
              if (_searchQuery.isEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.trending_up, color: Colors.white),
                  title: const Text('Top Charts', style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TopChartsScreen()),
                    );
                  },
                ),
                const Divider(color: Colors.white24),
              ],
              Expanded(
                child: _searchQuery.isEmpty
                    ? _RecentSearches(
                        recentSearches: _recentSearches,
                        onRecentTap: _onRecentTap,
                        onClear: _clearRecentSearches,
                      )
                    : BlocBuilder<AppBloc, AppState>(
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
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.search_off, size: 64, color: Colors.white70),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.noAppsFound,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
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
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> recentSearches;
  final Function(String) onRecentTap;
  final VoidCallback onClear;

  const _RecentSearches({
    required this.recentSearches,
    required this.onRecentTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'Start typing to search apps',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: const Text('Clear All', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches.map((search) {
            return ActionChip(
              avatar: const Icon(Icons.history, size: 16, color: Colors.white70),
              label: Text(search, style: const TextStyle(color: Colors.white)),
              onPressed: () => onRecentTap(search),
              backgroundColor: Colors.white.withOpacity(0.1),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}
