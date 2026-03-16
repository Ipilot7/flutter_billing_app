import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/billing_bloc.dart';

class PaymentMethodSheet extends StatelessWidget {
  final BillingState billingState;
  final Function(int type) onSelectPayment;

  const PaymentMethodSheet({
    super.key,
    required this.billingState,
    required this.onSelectPayment,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.paymentMethod,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.currency} ${billingState.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _PaymentOption(
                type: 0,
                icon: Icons.money,
                label: l10n.cash,
                onTap: () => onSelectPayment(0),
              ),
              const SizedBox(width: 12),
              _PaymentOption(
                type: 1,
                icon: Icons.credit_card,
                label: l10n.card,
                onTap: () => onSelectPayment(1),
              ),
              const SizedBox(width: 12),
              _PaymentOption(
                type: 2,
                icon: Icons.account_balance_wallet,
                label: l10n.terminal,
                onTap: () => onSelectPayment(2),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final int type;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.type,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
