import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sales/presentation/bloc/analytics_bloc.dart';

class TodayStatsBar extends StatelessWidget {
  const TodayStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is! AnalyticsLoaded) {
          return const SizedBox(height: 10);
        }

        final l = AppLocalizations.of(context)!;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              _StatItem(
                icon: Icons.receipt_long,
                label: l.transactions,
                value: state.sales.length.toString(),
              ),
              Container(width: 1, height: 24, color: Colors.grey[200]),
              _StatItem(
                icon: Icons.payments,
                label: l.revenue,
                value: '${l.currency} ${state.totalRevenue.toInt()}',
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isBold;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
                  color: isBold ? AppTheme.primaryColor : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
