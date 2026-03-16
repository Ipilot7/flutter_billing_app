import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class CashChangeDialog extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onComplete;

  const CashChangeDialog({
    super.key,
    required this.totalAmount,
    required this.onComplete,
  });

  @override
  State<CashChangeDialog> createState() => _CashChangeDialogState();
}

class _CashChangeDialogState extends State<CashChangeDialog> {
  final TextEditingController _controller = TextEditingController();
  double _change = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    return AlertDialog(
      title: Text(l10n.cash),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.total,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${l10n.currency} ${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Amount received
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.amountReceived,
              prefixText: '${l10n.currency} ',
              border: const OutlineInputBorder(),
            ),
            onChanged: (val) {
              setState(() {
                final received = double.tryParse(val) ?? 0;
                _change = received - widget.totalAmount;
              });
            },
          ),
          const SizedBox(height: 12),
          // Change
          if (_change >= 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.change,
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  Text(
                    '${l10n.currency} ${_change.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _change < 0 ? null : widget.onComplete,
          child: Text(l10n.completeSale),
        ),
      ],
    );
  }
}
