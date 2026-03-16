import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/analytics_bloc.dart';

class TopProductsList extends StatelessWidget {
  final AnalyticsLoaded state;

  const TopProductsList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
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
