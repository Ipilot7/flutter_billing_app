import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/billing_bloc.dart';

class CheckoutSummaryPanel extends StatelessWidget {
  final BillingState state;
  final VoidCallback onComplete;
  final Function(BuildContext, String, String, Function(String)) onEditDiscount;

  const CheckoutSummaryPanel({
    super.key,
    required this.state,
    required this.onComplete,
    required this.onEditDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.subtotal),
                Text('${l10n.currency} ${state.subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(l10n.discount, style: const TextStyle(color: Colors.orange)),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.orange),
                      onPressed: () => onEditDiscount(
                        context,
                        l10n.discount,
                        state.globalDiscount.toString(),
                        (val) {}, // Logic should be handled by caller through onSave or similar
                      ),
                    ),
                  ],
                ),
                Text(
                  '- ${l10n.currency} ${state.globalDiscount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '${l10n.currency} ${state.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: state.cartItems.isEmpty ? null : onComplete,
                label: Text(
                  l10n.completeSale,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                icon: const Icon(Icons.check_circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
