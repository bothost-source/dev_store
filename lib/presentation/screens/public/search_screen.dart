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
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  List<String> _recentSearches = [];
  List<String> _searchSuggestions = [];
  Timer? _debounceTimer;
  bool _showSuggestions = false;

  // Categories for filter chips
  final List<String> _categories = [
    'All',
    'Productivity',
    'Games',
    'Social',
    'Education',
    'Entertainment',
    'Tools',
    'Finance',
  ];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
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
    setState(() {
      _searchQuery = query;
      _showSuggestions = query.isNotEmpty && query.length >= 2;
    });

    if (query.isEmpty) {
      setState(() => _searchSuggestions = []);
      return;
    }

    // Debounce: wait 300ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query.length >= 2) {
        _fetchSuggestions(query);
        _performSearch(query);
      }
    });
  }

  void _fetchSuggestions(String query) {
    // Mock suggestions - replace with your API call
    final mockSuggestions = [
      '$query pro',
      '$query lite',
      '$query beta',
      'best $query apps',
      '$query for android',
    ];
    setState(() => _searchSuggestions = mockSuggestions);
  }

  void _performSearch(String query) {
    _saveRecentSearch(query);
    context.read<AppBloc>().add(
      LoadApps(
        searchQuery: query,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
      ),
    );
  }

  void _onSearchSubmitted(String query) {
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
    if (query.isNotEmpty) {
      _performSearch(query);
    }
  }

  void _onRecentTap(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    _onSearchSubmitted(query);
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.collapsed(offset: suggestion.length);
    _onSearchSubmitted(suggestion);
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
                textInputAction: TextInputAction.search,
                style: TextStyle(color: textColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: l10n.search,
                  hintStyle: TextStyle(color: mutedColor),
                  prefixIcon: Icon(Icons.search, color: mutedColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: mutedColor),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _showSuggestions = false;
                              _searchSuggestions = [];
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter Chips
            if (_searchQuery.isEmpty) ...[
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(category),
                        onSelected: (_) => _onCategorySelected(category),
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : mutedColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: surfaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.3)
                                : isDark
                                    ? Colors.white12
                                    : Colors.black.withOpacity(0.08),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Search Suggestions Overlay
            if (_showSuggestions && _searchSuggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _searchSuggestions.map((suggestion) {
                      return ListTile(
                        dense: true,
                        leading: Icon(Icons.search, size: 20, color: mutedColor),
                        title: Text(
                          suggestion,
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                        onTap: () => _onSuggestionTap(suggestion),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Top Charts Shortcut (when empty)
            if (_searchQuery.isEmpty && !_showSuggestions) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _TopChartsCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TopChartsScreen()),
                    );
                  },
                ),
              ),
            ],

            const Divider(height: 1),

            // Main Content
            Expanded(
              child: _searchQuery.isEmpty && !_showSuggestions
                  ? _RecentSearchesView(
                      recentSearches: _recentSearches,
                      onRecentTap: _onRecentTap,
                      onClear: _clearRecentSearches,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    )
                  : BlocBuilder<AppBloc, AppState>(
                      builder: (context, state) {
                        if (state is AppLoading) {
                          return const ShimmerAppList();
                        }
                        if (state is AppError) {
                          return _ErrorView(
                            message: state.message,
                            onRetry: () => _performSearch(_searchQuery),
                            textColor: textColor,
                          );
                        }
                        if (state is AppsLoaded) {
                          if (state.apps.isEmpty) {
                            return _EmptyResultsView(
                              query: _searchQuery,
                              textColor: textColor,
                              mutedColor: mutedColor,
                            );
                          }
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: state.apps.length,
                            itemBuilder: (context, index) {
                              final app = state.apps[index];
                              return AppCard(
                                app: app,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AppDetailScreen(app: app),
                                    ),
                                  );
                                },
                                showInstallButton: true,
                                onInstall: () {
                                  // Handle install
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

// ─────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────

class _TopChartsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _TopChartsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Charts',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Discover trending apps',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white40 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchesView extends StatelessWidget {
  final List<String> recentSearches;
  final Function(String) onRecentTap;
  final VoidCallback onClear;
  final Color textColor;
  final Color mutedColor;

  const _RecentSearchesView({
    required this.recentSearches,
    required this.onRecentTap,
    required this.onClear,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return _EmptySearchView(mutedColor: mutedColor);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches.map((search) {
            return ActionChip(
              avatar: Icon(Icons.history, size: 16, color: mutedColor),
              label: Text(search),
              onPressed: () => onRecentTap(search),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              side: BorderSide.none,
              labelStyle: TextStyle(color: textColor, fontSize: 13),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  final Color mutedColor;

  const _EmptySearchView({required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 48,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Search for apps',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: mutedColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your favorite apps and games',
            style: TextStyle(
              fontSize: 14,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResultsView extends StatelessWidget {
  final String query;
  final Color textColor;
  final Color mutedColor;

  const _EmptyResultsView({
    required this.query,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: mutedColor),
            const SizedBox(height: 20),
            Text(
              'No results for "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check your spelling',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color textColor;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
