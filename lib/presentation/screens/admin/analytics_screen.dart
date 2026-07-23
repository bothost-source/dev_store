import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/user_repository.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: UserRepository().getAnalytics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load analytics',
                    style: TextStyle(fontSize: 18, color: AppColors.error),
                  ),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          _animationController.forward();

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards Grid
                  _buildStatsGrid(data, isDark),

                  const SizedBox(height: 24),

                  // Downloads Trend Chart
                  _buildSectionTitle('Downloads Trend'),
                  const SizedBox(height: 12),
                  _buildLineChart(data['weeklyDownloads'] ?? _mockWeeklyData(), isDark),

                  const SizedBox(height: 24),

                  // App Categories Distribution
                  _buildSectionTitle('App Categories'),
                  const SizedBox(height: 12),
                  _buildPieChart(data['categoryDistribution'] ?? _mockCategoryData(), isDark),

                  const SizedBox(height: 24),

                  // Top Performing Apps
                  _buildSectionTitle('Top Performing Apps'),
                  const SizedBox(height: 12),
                  _buildTopAppsList(data['topApps'] ?? _mockTopApps(), isDark),

                  const SizedBox(height: 24),

                  // Pending Approvals Detail
                  if ((data['pendingApps'] ?? 0) > 0) ...[
                    _buildSectionTitle('Pending Actions'),
                    const SizedBox(height: 12),
                    _buildPendingCard(data['pendingApps'], isDark),
                    const SizedBox(height: 24),
                  ],

                  // Developer Activity
                  _buildSectionTitle('Developer Activity'),
                  const SizedBox(height: 12),
                  _buildBarChart(data['developerActivity'] ?? _mockDeveloperData(), isDark),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data, bool isDark) {
    final stats = [
      _StatData(
        title: 'Total Users',
        value: _formatNumber(data['totalUsers'] ?? 0),
        icon: Icons.people_alt_rounded,
        color: AppColors.primary,
        trend: data['usersTrend'] ?? 12.5,
      ),
      _StatData(
        title: 'Total Apps',
        value: _formatNumber(data['totalApps'] ?? 0),
        icon: Icons.apps_rounded,
        color: AppColors.secondary,
        trend: data['appsTrend'] ?? 8.3,
      ),
      _StatData(
        title: 'Downloads',
        value: _formatNumber(data['totalDownloads'] ?? 0),
        icon: Icons.download_rounded,
        color: AppColors.success,
        trend: data['downloadsTrend'] ?? 23.1,
      ),
      _StatData(
        title: 'Developers',
        value: _formatNumber(data['totalDevelopers'] ?? 0),
        icon: Icons.code_rounded,
        color: AppColors.infoColor,
        trend: data['developersTrend'] ?? 5.7,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _StatCard(
          stat: stat,
          isDark: isDark,
          delay: index * 100,
        );
      },
    );
  }

  Widget _buildLineChart(List<dynamic> weeklyData, bool isDark) {
    final spots = weeklyData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['count'] ?? 0).toDouble());
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 50,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white12 : Colors.black12,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 11,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
              ),
            ),
          ],
          minY: 0,
        ),
      ),
    );
  }

  Widget _buildPieChart(List<dynamic> categories, bool isDark) {
    final sections = categories.asMap().entries.map((e) {
      final cat = e.value;
      final colors = [
        AppColors.primary,
        AppColors.secondary,
        AppColors.success,
        AppColors.warning,
        AppColors.infoColor,
        AppColors.error,
      ];
      return PieChartSectionData(
        value: (cat['count'] ?? 0).toDouble(),
        title: '${cat['count']}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: colors[e.key % colors.length],
        badgeWidget: cat['count'] > 10
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(cat['name']),
                  size: 14,
                  color: colors[e.key % colors.length],
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.asMap().entries.map((e) {
                final colors = [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.success,
                  AppColors.warning,
                  AppColors.infoColor,
                  AppColors.error,
                ];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> activityData, bool isDark) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: activityData.fold<double>(
            0,
            (max, e) => (e['count'] ?? 0) > max ? (e['count'] ?? 0).toDouble() : max,
          ) * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.primary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${activityData[groupIndex]['name']}\n',
                  const TextStyle(color: Colors.white, fontSize: 12),
                  children: [
                    TextSpan(
                      text: '${activityData[groupIndex]['count']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < activityData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        activityData[value.toInt()]['name'] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white12 : Colors.black12,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: activityData.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: (e.value['count'] ?? 0).toDouble(),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopAppsList(List<dynamic> topApps, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topApps.length.clamp(0, 5),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: isDark ? Colors.white12 : Colors.black12,
        ),
        itemBuilder: (context, index) {
          final app = topApps[index];
          return ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            title: Text(
              app['name'] ?? 'Unknown App',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${_formatNumber(app['downloads'] ?? 0)} downloads',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${app['growth'] ?? 0}%',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingCard(int count, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning.withOpacity(0.1), AppColors.warning.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.pending_actions, color: AppColors.warning, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Apps Pending Approval',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review and approve submitted apps',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to approvals screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final n = number is int ? number : int.tryParse(number.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  IconData _getCategoryIcon(String? name) {
    switch (name?.toLowerCase()) {
      case 'productivity':
        return Icons.work_outline;
      case 'games':
        return Icons.sports_esports;
      case 'social':
        return Icons.people_outline;
      case 'education':
        return Icons.school_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      default:
        return Icons.apps;
    }
  }

  // Mock data fallbacks — remove once your API returns these fields
  List<Map<String, dynamic>> _mockWeeklyData() => [
    {'day': 'Mon', 'count': 120},
    {'day': 'Tue', 'count': 190},
    {'day': 'Wed', 'count': 150},
    {'day': 'Thu', 'count': 280},
    {'day': 'Fri', 'count': 220},
    {'day': 'Sat', 'count': 340},
    {'day': 'Sun', 'count': 290},
  ];

  List<Map<String, dynamic>> _mockCategoryData() => [
    {'name': 'Productivity', 'count': 45},
    {'name': 'Games', 'count': 32},
    {'name': 'Social', 'count': 28},
    {'name': 'Education', 'count': 20},
    {'name': 'Entertainment', 'count': 15},
  ];

  List<Map<String, dynamic>> _mockDeveloperData() => [
    {'name': 'Jan', 'count': 12},
    {'name': 'Feb', 'count': 18},
    {'name': 'Mar', 'count': 25},
    {'name': 'Apr', 'count': 22},
    {'name': 'May', 'count': 30},
    {'name': 'Jun', 'count': 35},
  ];

  List<Map<String, dynamic>> _mockTopApps() => [
    {'name': 'TaskMaster Pro', 'downloads': 15420, 'growth': 23},
    {'name': 'Pixel Runner', 'downloads': 12890, 'growth': 18},
    {'name': 'ChatFlow', 'downloads': 11200, 'growth': 15},
    {'name': 'LearnCode', 'downloads': 9800, 'growth': 12},
    {'name': 'MusicBox', 'downloads': 8500, 'growth': 9},
  ];
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double trend;

  _StatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });
}

class _StatCard extends StatefulWidget {
  final _StatData stat;
  final bool isDark;
  final int delay;

  const _StatCard({
    required this.stat,
    required this.isDark,
    required this.delay,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.stat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.stat.icon, color: widget.stat.color, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.stat.trend >= 0
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.stat.trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: widget.stat.trend >= 0 ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.stat.trend.abs()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: widget.stat.trend >= 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.stat.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.stat.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isDark ? Colors.white60 : Colors.black54,
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
