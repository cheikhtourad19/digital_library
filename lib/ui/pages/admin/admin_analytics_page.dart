import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/toast_service.dart';
import '../../../models/stats_model.dart';
import '../../../service/stats_service.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  final StatsService _statsService = getIt<StatsService>();

  bool _isLoading = true;
  int _days = 30;
  String _selectedAgeGroup = '18-25';
  bool _showAllTopLivres = false;
  bool _showAllTopCategories = false;
  bool _showAllCategoriesByAge = false;

  StatsOverview? _overview;
  UsersStats? _usersStats;
  SalesTrendStats? _salesTrend;
  List<TopLivreStat> _topLivres = const <TopLivreStat>[];

  List<CategoryStat> _categories = const <CategoryStat>[];
  TopCategoriesByAgeStats? _categoriesByAge;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait<dynamic>([
        _statsService.getOverview(days: _days),
        _statsService.getSalesTrend(days: _days),
        _statsService.getUsersStats(days: _days),
        _statsService.getTopLivres(limit: 8),
        _statsService.getCategoriesStats(limit: 8),
        _statsService.getTopCategoriesByAge(_selectedAgeGroup),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _overview = results[0] as StatsOverview;
        _salesTrend = results[1] as SalesTrendStats;
        _usersStats = results[2] as UsersStats;
        _topLivres = results[3] as List<TopLivreStat>;
        _categories = results[4] as List<CategoryStat>;
        _categoriesByAge = results[5] as TopCategoriesByAgeStats;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ToastService.showError('Failed to load analytics');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: _loadAnalytics,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildKpiGrid(),
                  const SizedBox(height: 12),
                  _buildSalesTrendCard(),
                  const SizedBox(height: 12),
                  _buildUsersTrendCard(),
                  const SizedBox(height: 12),
                  _buildTopLists(context),
                  const SizedBox(height: 12),
                  _buildCategoriesByAgeCard(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Live business metrics from your backend stats APIs',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildDaysDropdown(),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _loadAnalytics,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _days,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: const [
            DropdownMenuItem(value: 7, child: Text('7d')),
            DropdownMenuItem(value: 30, child: Text('30d')),
            DropdownMenuItem(value: 90, child: Text('90d')),
            DropdownMenuItem(value: 365, child: Text('1y')),
          ],
          onChanged: (value) {
            if (value == null || value == _days) {
              return;
            }
            setState(() => _days = value);
            _loadAnalytics();
          },
        ),
      ),
    );
  }

  Widget _buildKpiGrid() {
    final overview = _overview;
    if (overview == null) {
      return const SizedBox.shrink();
    }

    final cards = <_KpiData>[
      _KpiData(
        title: 'Revenue (${_days}d)',
        value: '${_formatAmount(overview.sales.inWindow.revenue)} TND',
        subtitle: '${overview.sales.inWindow.orders} confirmed orders',
        icon: Icons.payments_rounded,
        accent: AppColors.secondary,
      ),
      _KpiData(
        title: 'Books Sold (${_days}d)',
        value: _formatInt(overview.sales.inWindow.booksSold),
        subtitle: 'All-time: ${_formatInt(overview.sales.allTime.booksSold)}',
        icon: Icons.menu_book_rounded,
        accent: AppColors.primary,
      ),
      _KpiData(
        title: 'Average Order Value',
        value: '${_formatAmount(overview.sales.avgOrderValue)} TND',
        subtitle: 'Based on confirmed sales',
        icon: Icons.show_chart_rounded,
        accent: AppColors.accent,
      ),
      _KpiData(
        title: 'New Users (${_days}d)',
        value: _formatInt(overview.users.newInWindow),
        subtitle: 'Total users: ${_formatInt(overview.users.total)}',
        icon: Icons.person_add_alt_1_rounded,
        accent: AppColors.secondary,
      ),
      _KpiData(
        title: 'Active Users',
        value: _formatInt(overview.users.active),
        subtitle: 'Inactive: ${_formatInt(overview.users.inactive)}',
        icon: Icons.groups_rounded,
        accent: AppColors.primary,
      ),
      _KpiData(
        title: 'New Books (${_days}d)',
        value: _formatInt(overview.livres.newInWindow),
        subtitle: 'Total books: ${_formatInt(overview.livres.total)}',
        icon: Icons.auto_stories_rounded,
        accent: AppColors.accent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const crossAxisCount = 2;
        const spacing = 10.0;

        final itemWidth =
            (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;
        const itemHeight = 120.0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((kpi) {
            return SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: _KpiCard(data: kpi),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSalesTrendCard() {
    final trend = _salesTrend?.points ?? const <SalesTrendPoint>[];
    return _CardShell(
      title: 'Sales Trend',
      subtitle: 'Confirmed sales revenue over time',
      child: trend.isEmpty
          ? _buildEmptyState('No sales trend data yet')
          : SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _computeInterval(
                      trend.map((e) => e.revenue).toList(),
                    ),
                    getDrawingHorizontalLine: (value) =>
                        const FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppColors.border),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: AppColors.secondary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.secondary.withOpacity(0.12),
                      ),
                      spots: _buildSalesSpots(trend),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: _computeInterval(
                          trend.map((e) => e.revenue).toList(),
                        ),
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            _formatCompactAmount(value),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _xInterval(trend.length),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= trend.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _shortDateLabel(trend[index].period),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildUsersTrendCard() {
    final points =
        _usersStats?.registrationsTrend.points ?? const <RegistrationPoint>[];

    return _CardShell(
      title: 'User Registrations',
      subtitle: 'New user signups across the selected window',
      child: points.isEmpty
          ? _buildEmptyState('No registration trend data yet')
          : SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) =>
                        const FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppColors.border),
                  ),
                  barGroups: _buildRegistrationBars(points),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _xInterval(points.length),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _shortDateLabel(points[index].period),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTopLists(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 980;

    final topBooksCard = _CardShell(
      title: 'Top Livres',
      subtitle: 'Best-performing books by copies sold',
      child: _topLivres.isEmpty
          ? _buildEmptyState('No top livres data yet')
          : _buildExpandableMetricList(
              items: _topLivres,
              isExpanded: _showAllTopLivres,
              visibleCount: 3,
              onToggle: () {
                setState(() => _showAllTopLivres = !_showAllTopLivres);
              },
              itemBuilder: (item) => _ListTileMetric(
                title: item.titre,
                subtitle: item.auteur.isEmpty
                    ? 'No author'
                    : item.auteur.join(', '),
                trailingTop: '${_formatInt(item.copiesSold)} sold',
                trailingBottom: '${_formatAmount(item.revenue)} TND',
              ),
            ),
    );

    final categoriesCard = _CardShell(
      title: 'Top Categories',
      subtitle: 'Category performance by sold copies',
      child: _categories.isEmpty
          ? _buildEmptyState('No categories stats data yet')
          : _buildExpandableMetricList(
              items: _categories,
              isExpanded: _showAllTopCategories,
              visibleCount: 3,
              onToggle: () {
                setState(() => _showAllTopCategories = !_showAllTopCategories);
              },
              itemBuilder: (item) => _ListTileMetric(
                title: item.nom,
                subtitle:
                    '${_formatInt(item.uniqueLivres)} unique livres • ${_formatInt(item.ordersCount)} orders',
                trailingTop: '${_formatInt(item.copiesSold)} sold',
                trailingBottom: '${_formatAmount(item.revenue)} TND',
              ),
            ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: topBooksCard),
          const SizedBox(width: 10),
          Expanded(child: categoriesCard),
        ],
      );
    }

    return Column(
      children: [topBooksCard, const SizedBox(height: 10), categoriesCard],
    );
  }

  Widget _buildCategoriesByAgeCard() {
    final categories = _categoriesByAge?.items ?? const <CategoryStat>[];

    return _CardShell(
      title: 'Categories by Age Group',
      subtitle: 'Top categories for selected age group',
      child: Column(
        children: [
          Wrap(
            spacing: 6,
            children: AgeGroup.all
                .map(
                  (ageGroup) => FilterChip(
                    selected: _selectedAgeGroup == ageGroup.label,
                    label: Text(ageGroup.label),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedAgeGroup = ageGroup.label);
                        _loadCategoriesByAge();
                      }
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          categories.isEmpty
              ? _buildEmptyState('No categories data for this age group')
              : _buildExpandableMetricList(
                  items: categories,
                  isExpanded: _showAllCategoriesByAge,
                  visibleCount: 3,
                  onToggle: () {
                    setState(
                      () => _showAllCategoriesByAge = !_showAllCategoriesByAge,
                    );
                  },
                  itemBuilder: (item) => _ListTileMetric(
                    title: item.nom,
                    subtitle:
                        '${_formatInt(item.uniqueLivres)} unique livres • ${_formatInt(item.ordersCount)} orders',
                    trailingTop: '${_formatInt(item.copiesSold)} sold',
                    trailingBottom: '${_formatAmount(item.revenue)} TND',
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildExpandableMetricList<T>({
    required List<T> items,
    required bool isExpanded,
    required int visibleCount,
    required Widget Function(T item) itemBuilder,
    required VoidCallback onToggle,
  }) {
    final displayItems = isExpanded ? items : items.take(visibleCount).toList();
    final hasMoreItems = items.length > visibleCount;

    return Column(
      children: [
        ...displayItems.map(itemBuilder),
        if (hasMoreItems)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onToggle,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: Icon(
                isExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 18,
              ),
              label: Text(isExpanded ? 'Voir moins' : 'Voir plus'),
            ),
          ),
      ],
    );
  }

  Future<void> _loadCategoriesByAge() async {
    try {
      final result = await _statsService.getTopCategoriesByAge(
        _selectedAgeGroup,
      );
      if (mounted) {
        setState(() => _categoriesByAge = result);
      }
    } catch (_) {
      if (mounted) {
        ToastService.showError('Failed to load categories by age group');
      }
    }
  }

  List<FlSpot> _buildSalesSpots(List<SalesTrendPoint> points) {
    return List.generate(
      points.length,
      (index) => FlSpot(index.toDouble(), points[index].revenue),
    );
  }

  List<BarChartGroupData> _buildRegistrationBars(
    List<RegistrationPoint> points,
  ) {
    return List.generate(
      points.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: points[index].users.toDouble(),
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
            width: points.length > 40
                ? 4
                : points.length > 20
                ? 7
                : 10,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  double _xInterval(int length) {
    if (length <= 8) {
      return 1;
    }
    if (length <= 20) {
      return 2;
    }
    return (length / 8).ceilToDouble();
  }

  double _computeInterval(List<double> values) {
    if (values.isEmpty) {
      return 1;
    }

    final maxValue = values.reduce(math.max);
    if (maxValue <= 0) {
      return 1;
    }

    final rough = maxValue / 4;
    if (rough <= 1) {
      return 1;
    }

    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor());
    final normalized = rough / magnitude;

    double step;
    if (normalized < 1.5) {
      step = 1;
    } else if (normalized < 3) {
      step = 2;
    } else if (normalized < 7) {
      step = 5;
    } else {
      step = 10;
    }

    return step * magnitude;
  }

  String _shortDateLabel(String raw) {
    if (raw.length >= 10) {
      return raw.substring(5, 10);
    }
    return raw;
  }

  String _formatInt(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  String _formatAmount(double value) {
    final rounded = value.toStringAsFixed(2);
    final split = rounded.split('.');
    return '${_formatInt(int.tryParse(split[0]) ?? 0)}.${split[1]}';
  }

  String _formatCompactAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}

class _CardShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CardShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(data.icon, color: data.accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTileMetric extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailingTop;
  final String trailingBottom;

  const _ListTileMetric({
    required this.title,
    required this.subtitle,
    required this.trailingTop,
    required this.trailingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trailingTop,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                trailingBottom,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
