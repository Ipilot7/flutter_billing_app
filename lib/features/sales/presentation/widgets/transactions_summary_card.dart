import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/analytics_bloc.dart';

class TransactionsSummaryCard extends StatelessWidget {
  final AnalyticsLoaded state;

  const TransactionsSummaryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
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
          _statItem(l.transactions, salesCount.toString(), AppTheme.primaryColor),
          _divider(),
          _statItem(l.returnSale, returnsCount.toString(), Colors.red),
          _divider(),
          _statItem('Avg.', '${l.currency} ${avgSale.toStringAsFixed(0)}', Colors.orange),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
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

  Widget _divider() {
    return Container(
        width: 1,
        height: 40,
        color: Colors.grey[200],
        margin: const EdgeInsets.symmetric(horizontal: 8));
  }
}
