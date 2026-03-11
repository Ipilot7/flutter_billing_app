import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../shift/presentation/bloc/shift_bloc.dart';
import '../bloc/billing_bloc.dart';
import '../../domain/entities/cart_item.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        context.read<BillingBloc>().add(ClearCartEvent());
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.checkout,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () {
              context.read<BillingBloc>().add(ClearCartEvent());
              context.go('/');
            },
          ),
          actions: [
            BlocBuilder<ShopBloc, ShopState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.print_outlined),
                  onPressed: () => _printOnly(context, state),
                  tooltip: AppLocalizations.of(context)!.printReceiptOnly,
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<BillingBloc, BillingState>(
          listener: (context, state) {
            if (state.printSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.printSuccess),
                  backgroundColor: Colors.green));
            }
            if (state.cartItems.isEmpty && state.error == null) {
              context.go('/');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.saleCompleted),
                  backgroundColor: Colors.green));
            }
          },
          builder: (context, billingState) {
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: billingState.cartItems.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final item = billingState.cartItems[index];
                      return _buildItemEditor(context, item);
                    },
                  ),
                ),
                _buildSummaryPanel(context, billingState),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemEditor(BuildContext context, CartItem item) {
    final isLowStock =
        item.product.stock > 0 && item.quantity > item.product.stock;
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
                  Text(item.product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(item.product.barcode,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  if (isLowStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${AppLocalizations.of(context)!.stock}: ${item.product.stock % 1 == 0 ? item.product.stock.toInt() : item.product.stock}',
                            style: const TextStyle(
                                color: Colors.orange, fontSize: 11),
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
                  '${AppLocalizations.of(context)!.currency} ${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => context
                      .read<BillingBloc>()
                      .add(RemoveProductFromCartEvent(item.product.id)),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline,
                          size: 14, color: Colors.red),
                      const SizedBox(width: 2),
                      Text(AppLocalizations.of(context)!.delete,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12)),
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
            _buildSmallEditor(
              label: AppLocalizations.of(context)!.quantity,
              value: item.quantity % 1 == 0
                  ? item.quantity.toInt().toString()
                  : item.quantity.toStringAsFixed(2),
              onTap: () => _editValue(
                context,
                title: AppLocalizations.of(context)!.quantity,
                initialValue: item.quantity.toString(),
                onSave: (val) => context.read<BillingBloc>().add(
                    UpdateQuantityEvent(item.product.id, double.parse(val))),
              ),
            ),
            const SizedBox(width: 12),
            _buildSmallEditor(
              label: AppLocalizations.of(context)!.price,
              value: item.price.toStringAsFixed(2),
              onTap: () => _editValue(
                context,
                title: AppLocalizations.of(context)!.price,
                initialValue: item.price.toString(),
                onSave: (val) => context.read<BillingBloc>().add(
                    UpdatePriceOverrideEvent(
                        item.product.id, double.parse(val))),
              ),
            ),
            const SizedBox(width: 12),
            _buildSmallEditor(
              label: AppLocalizations.of(context)!.discount,
              value: item.discount.toStringAsFixed(2),
              onTap: () => _editValue(
                context,
                title: AppLocalizations.of(context)!.discount,
                initialValue: item.discount.toString(),
                onSave: (val) => context.read<BillingBloc>().add(
                    UpdateItemDiscountEvent(
                        item.product.id, double.parse(val))),
              ),
              color: Colors.orange[800],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallEditor({
    required String label,
    required String value,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: (color ?? Colors.blue).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: (color ?? Colors.blue).withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      TextStyle(fontSize: 10, color: (color ?? Colors.blue))),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPanel(BuildContext context, BillingState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.subtotal),
                Text(
                    '${AppLocalizations.of(context)!.currency} ${state.subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!.discount,
                        style: const TextStyle(color: Colors.orange)),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 16, color: Colors.orange),
                      onPressed: () => _editValue(
                        context,
                        title: AppLocalizations.of(context)!.discount,
                        initialValue: state.globalDiscount.toString(),
                        onSave: (val) => context
                            .read<BillingBloc>()
                            .add(UpdateGlobalDiscountEvent(double.parse(val))),
                      ),
                    ),
                  ],
                ),
                Text(
                    '- ${AppLocalizations.of(context)!.currency} ${state.globalDiscount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.total,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  '${AppLocalizations.of(context)!.currency} ${state.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onPressed: state.cartItems.isEmpty
                        ? null
                        : () => _showPaymentSheet(context, state),
                    label: AppLocalizations.of(context)!.completeSale,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editValue(
    BuildContext context, {
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
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
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, BillingState billingState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) =>
          BlocBuilder<ShopBloc, ShopState>(builder: (context, shopState) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.paymentMethod,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '${AppLocalizations.of(context)!.currency} ${billingState.totalAmount.toStringAsFixed(2)}',
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
                  _buildPaymentOption(context, 0, Icons.money,
                      AppLocalizations.of(context)!.cash, shopState,
                      billingState: billingState),
                  const SizedBox(width: 12),
                  _buildPaymentOption(context, 1, Icons.credit_card,
                      AppLocalizations.of(context)!.card, shopState,
                      billingState: billingState),
                  const SizedBox(width: 12),
                  _buildPaymentOption(context, 2, Icons.account_balance_wallet,
                      AppLocalizations.of(context)!.terminal, shopState,
                      billingState: billingState),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    int type,
    IconData icon,
    String label,
    ShopState shopState, {
    required BillingState billingState,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          final shiftBloc = context.read<ShiftBloc>();
          final currentShift = shiftBloc.currentShift;
          if (currentShift == null) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.pleaseOpenShift),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ));
            return;
          }

          // Cash: show change calculator
          if (type == 0) {
            _showCashChangeDialog(
                context, billingState.totalAmount, currentShift, shopState);
          } else {
            _completeSale(context, currentShift.id, currentShift.openedBy, type,
                shopState);
          }
        },
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

  void _completeSale(BuildContext context, String shiftId, String openedBy,
      int paymentType, ShopState shopState) {
    context.read<BillingBloc>().add(CompleteSaleEvent(
          shiftId: shiftId,
          openedBy: openedBy,
          paymentType: paymentType,
        ));

    // Auto print after sale
    if (shopState is ShopLoaded) {
      context.read<BillingBloc>().add(PrintReceiptEvent(
            shopName: shopState.shop.name,
            address1: shopState.shop.addressLine1,
            address2: shopState.shop.addressLine2,
            phone: shopState.shop.phoneNumber,
            footer: shopState.shop.footerText,
          ));
    }

    Navigator.pop(context);
  }

  void _showCashChangeDialog(BuildContext context, double totalAmount,
      dynamic currentShift, ShopState shopState) {
    final controller = TextEditingController();
    double change = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.cash),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.total,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text(
                      '${AppLocalizations.of(context)!.currency} ${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Amount received
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amountReceived,
                  prefixText: '${AppLocalizations.of(context)!.currency} ',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setDialogState(() {
                    final received = double.tryParse(val) ?? 0;
                    change = received - totalAmount;
                  });
                },
              ),
              const SizedBox(height: 12),
              // Change
              if (change >= 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.change,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.green)),
                      Text(
                        '${AppLocalizations.of(context)!.currency} ${change.toStringAsFixed(2)}',
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
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: change < 0
                  ? null
                  : () {
                      Navigator.pop(ctx); // close dialog
                      _completeSale(context, currentShift.id,
                          currentShift.openedBy, 0, shopState);
                    },
              child: Text(AppLocalizations.of(context)!.completeSale),
            ),
          ],
        ),
      ),
    );
  }

  void _printOnly(BuildContext context, ShopState shopState) {
    if (shopState is ShopLoaded) {
      context.read<BillingBloc>().add(PrintReceiptEvent(
            shopName: shopState.shop.name,
            address1: shopState.shop.addressLine1,
            address2: shopState.shop.addressLine2,
            phone: shopState.shop.phoneNumber,
            footer: shopState.shop.footerText,
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.shopDetailsNotLoaded),
        backgroundColor: Colors.red,
      ));
    }
  }
}
