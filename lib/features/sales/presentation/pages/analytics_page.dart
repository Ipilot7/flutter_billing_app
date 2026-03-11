import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics_bloc.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedPeriod = 0; // 0: today, 1: week, 2: month

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final now = DateTime.now();
    DateTime from;
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedPeriod) {
      case 0:
        from = DateTime(now.year, now.month, now.day);
        break;
      case 1:
        from = now.subtract(const Duration(days: 7));
        break;
      case 2:
        from = DateTime(now.year, now.month, 1);
        break;
      default:
        from = DateTime(now.year, now.month, now.day);
    }

    context.read<AnalyticsBloc>().add(LoadAnalyticsEvent(from: from, to: to));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(l.analytics,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AnalyticsError) {
                  return Center(child: Text(state.message));
                }
                if (state is AnalyticsLoaded) {
                  return _buildDashboard(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final l = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _periodChip(0, l.today),
          const SizedBox(width: 8),
          _periodChip(1, l.thisWeek),
          const SizedBox(width: 8),
          _periodChip(2, l.thisMonth),
        ],
      ),
    );
  }

  Widget _periodChip(int index, String label) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() => _selectedPeriod = index);
          _loadData();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(AnalyticsLoaded state) {
    final l = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stat cards
        Row(
          children: [
            _buildStatCard(
              l.revenue,
              state.totalRevenue,
              AppTheme.primaryColor,
              Icons.trending_up_rounded,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              l.profit,
              state.totalProfit,
              Colors.green,
              Icons.attach_money_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Transactions count card
        _buildTransactionsCard(state),
        const SizedBox(height: 20),

        // Daily Revenue chart (only for week/month)
        if (_selectedPeriod != 0 && state.sales.isNotEmpty) ...[
          _buildSectionTitle(l.dailyRevenue),
          const SizedBox(height: 12),
          _buildDailyRevenueChart(state.sales),
          const SizedBox(height: 24),
        ],

        // Payment breakdown
        _buildSectionTitle(l.salesByPayment),
        const SizedBox(height: 12),
        _buildPaymentPieChart(state),
        const SizedBox(height: 24),

        // Top products
        _buildSectionTitle(l.topProducts),
        const SizedBox(height: 12),
        _buildTopProductsList(state),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatCard(
      String title, double value, Color color, IconData icon) {
    final l = AppLocalizations.of(context)!;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              '${l.currency} ${value.toStringAsFixed(0)}',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsCard(AnalyticsLoaded state) {
    final l = AppLocalizations.of(context)!;
    final salesCount = state.sales.where((s) => !s.isReturned).length;
    final returnsCount = state.sales.where((s) => s.isReturned).length;
    final avgSale = salesCount > 0 ? state.totalRevenue / salesCount : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _transactionStat(
              l.transactions, salesCount.toString(), AppTheme.primaryColor),
          _transactionDivider(),
          _transactionStat(l.returnSale, returnsCount.toString(), Colors.red),
          _transactionDivider(),
          _transactionStat('Avg.',
              '${l.currency} ${avgSale.toStringAsFixed(0)}', Colors.orange),
        ],
      ),
    );
  }

  Widget _transactionStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _transactionDivider() {
    return Container(
        width: 1,
        height: 40,
        color: Colors.grey[200],
        margin: const EdgeInsets.symmetric(horizontal: 8));
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
  }

  Widget _buildDailyRevenueChart(List<Sale> sales) {
    // Group revenue by day
    final Map<String, double> dailyRevenue = {};
    final dateKey = DateFormat('MM/dd');

    for (final sale in sales) {
      if (!sale.isReturned) {
        final key = dateKey.format(sale.createdAt);
        dailyRevenue[key] = (dailyRevenue[key] ?? 0) + sale.totalAmount;
      }
    }

    if (dailyRevenue.isEmpty) return const SizedBox.shrink();

    final sortedKeys = dailyRevenue.keys.toList()..sort();
    final maxY = dailyRevenue.values.reduce((a, b) => a > b ? a : b);

    final spots = sortedKeys.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), dailyRevenue[e.value]!);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[100]!,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    value >= 1000000
                        ? '${(value / 1000000).toStringAsFixed(1)}M'
                        : value >= 1000
                            ? '${(value / 1000).toStringAsFixed(0)}k'
                            : value.toStringAsFixed(0),
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: sortedKeys.length > 7
                    ? (sortedKeys.length / 7).ceilToDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= sortedKeys.length || idx < 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(sortedKeys[idx],
                        style: TextStyle(fontSize: 9, color: Colors.grey[400])),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: spots.length <= 10,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: AppTheme.primaryColor,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                    AppTheme.primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          minY: 0,
          maxY: maxY * 1.2,
        ),
      ),
    );
  }

  Widget _buildPaymentPieChart(AnalyticsLoaded state) {
    final l = AppLocalizations.of(context)!;
    final Map<int, String> labels = {
      0: l.cash,
      1: l.card,
      2: l.terminal,
    };
    final Map<int, Color> colors = {
      0: Colors.green[600]!,
      1: AppTheme.primaryColor,
      2: Colors.orange,
    };

    if (state.totalRevenue == 0) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        alignment: Alignment.center,
        child: Text(l.noSales,
            style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      );
    }

    final sections = state.salesByPayment.entries
        .where((e) => e.value > 0)
        .map((e) => PieChartSectionData(
              value: e.value,
              title: '${(e.value / state.totalRevenue * 100).toInt()}%',
              color: colors[e.key],
              radius: 52,
              titleStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ))
        .toList();

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: PieChart(PieChartData(
                sections: sections, centerSpaceRadius: 28, sectionsSpace: 2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.salesByPayment.entries.map((e) {
                final l = AppLocalizations.of(context)!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[e.key],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(labels[e.key]!,
                            style: const TextStyle(fontSize: 12)),
                      ),
                      Text(
                        '${l.currency} ${e.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
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

  Widget _buildTopProductsList(AnalyticsLoaded state) {
    final l = AppLocalizations.of(context)!;
    if (state.topProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        alignment: Alignment.center,
        child: Text(l.noSales, style: TextStyle(color: Colors.grey[400])),
      );
    }

    final entries = state.topProducts.entries.take(5).toList();
    final maxValue = entries.first.value;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: entries.asMap().entries.map((entry) {
          final idx = entry.key;
          final e = entry.value;
          final ratio = maxValue > 0 ? e.value / maxValue : 0.0;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: idx == 0
                            ? Colors.amber
                            : idx == 1
                                ? Colors.grey[400]
                                : idx == 2
                                    ? Colors.brown[300]
                                    : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Text('${idx + 1}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  idx < 3 ? Colors.white : Colors.grey[600])),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.key,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      '${l.currency} ${e.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      idx == 0
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              if (idx < entries.length - 1)
                Divider(height: 1, color: Colors.grey[100]),
            ],
          );
        }).toList(),
      ),
    );
  }
}
