import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/billing_bloc.dart';

class CheckoutItemEditor extends StatelessWidget {
  final CartItem item;

  const CheckoutItemEditor({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLowStock = item.product.stock > 0 && item.quantity > item.product.stock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    item.product.barcode,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  if (isLowStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${l10n.stock}: ${item.product.stock % 1 == 0 ? item.product.stock.toInt() : item.product.stock}',
                            style: const TextStyle(color: Colors.orange, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${l10n.currency} ${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => context.read<BillingBloc>().add(
                        RemoveProductFromCartEvent(item.product.id),
                      ),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                      const SizedBox(width: 2),
                      Text(
                        l10n.delete,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _SmallEditor(
              label: l10n.quantity,
              value: item.quantity % 1 == 0
                  ? item.quantity.toInt().toString()
                  : item.quantity.toStringAsFixed(2),
              onTap: () => _showEditDialog(
                context,
                title: l10n.quantity,
                initialValue: item.quantity.toString(),
                onSave: (val) => context.read<BillingBloc>().add(
                      UpdateQuantityEvent(item.product.id, double.tryParse(val) ?? 0.0),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            _SmallEditor(
              label: l10n.price,
              value: item.price.toStringAsFixed(2),
              onTap: () => _showEditDialog(
                context,
                title: l10n.price,
                initialValue: item.price.toString(),
                onSave: (val) => context.read<BillingBloc>().add(
                      UpdatePriceOverrideEvent(item.product.id, double.tryParse(val) ?? 0.0),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            _SmallEditor(
              label: l10n.discount,
              value: item.discount.toStringAsFixed(2),
              onTap: () => _showEditDialog(
                context,
                title: l10n.discount,
                initialValue: item.discount.toString(),
                onSave: (val) => context.read<BillingBloc>().add(
                      UpdateItemDiscountEvent(item.product.id, double.tryParse(val) ?? 0.0),
                    ),
              ),
              color: Colors.orange[800],
            ),
          ],
        ),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _SmallEditor extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? color;

  const _SmallEditor({
    required this.label,
    required this.value,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.blue;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: effectiveColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: effectiveColor),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
