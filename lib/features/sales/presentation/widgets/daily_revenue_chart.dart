import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/sale.dart';

class DailyRevenueChart extends StatelessWidget {
  final List<Sale> sales;

  const DailyRevenueChart({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
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
}
