import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/analytics_bloc.dart';

class PaymentPieChart extends StatelessWidget {
  final AnalyticsLoaded state;

  const PaymentPieChart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
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
}
