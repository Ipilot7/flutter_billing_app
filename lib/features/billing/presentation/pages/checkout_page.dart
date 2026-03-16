import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../shift/presentation/bloc/shift_bloc.dart';
import '../bloc/billing_bloc.dart';

import '../widgets/checkout_item_editor.dart';
import '../widgets/checkout_summary_panel.dart';
import '../widgets/payment_method_sheet.dart';
import '../widgets/cash_change_dialog.dart';
import '../widgets/checkout_helper.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        context.read<BillingBloc>().add(ClearCartEvent());
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.checkout,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  tooltip: l10n.printReceiptOnly,
                );
              },
            ),
          ],
        ),
        body: BlocListener<BillingBloc, BillingState>(
          listener: (context, state) {
            if (state.printSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(l10n.printSuccess),
                  backgroundColor: Colors.green));
            }
            if (state.cartItems.isEmpty && state.error == null) {
              context.go('/');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(l10n.saleCompleted),
                  backgroundColor: Colors.green));
            }
          },
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<BillingBloc, BillingState>(
                  buildWhen: (previous, current) =>
                      previous.cartItems != current.cartItems,
                  builder: (context, state) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.cartItems.length,
                      separatorBuilder: (context, index) => const Divider(height: 32),
                      itemBuilder: (context, index) {
                        final item = state.cartItems[index];
                        return CheckoutItemEditor(item: item);
                      },
                    );
                  },
                ),
              ),
              BlocBuilder<BillingBloc, BillingState>(
                buildWhen: (previous, current) =>
                    previous.cartItems.isEmpty != current.cartItems.isEmpty ||
                    previous.subtotal != current.subtotal ||
                    previous.globalDiscount != current.globalDiscount ||
                    previous.totalAmount != current.totalAmount,
                builder: (context, state) {
                  return CheckoutSummaryPanel(
                    state: state,
                    onComplete: () => _showPaymentSheet(context, state),
                    onEditDiscount: (ctx, title, initialValue, _) => 
                        CheckoutHelper.editGlobalDiscount(context, initialValue),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, BillingState billingState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => BlocBuilder<ShopBloc, ShopState>(
        builder: (context, shopState) {
          return PaymentMethodSheet(
            billingState: billingState,
            onSelectPayment: (type) async {
              final shiftBloc = context.read<ShiftBloc>();
              final currentShift = shiftBloc.currentShift;

              final resolved = await CheckoutHelper.resolveShiftForSale(context, currentShift);
              if (!context.mounted) return;
              if (resolved == null) {
                Navigator.pop(ctx);
                return;
              }

              final shiftId = resolved.$1;
              final openedBy = resolved.$2;

              if (type == 0) {
                Navigator.pop(ctx); // Close sheet before dialog
                _showCashChangeDialog(context, billingState.totalAmount, shiftId, openedBy, shopState);
              } else {
                _completeSale(context, shiftId, openedBy, type, shopState);
                Navigator.pop(ctx);
              }
            },
          );
        },
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

    if (shopState is ShopLoaded) {
      context.read<BillingBloc>().add(PrintReceiptEvent(
            shopName: shopState.shop.name,
            address1: shopState.shop.addressLine1,
            address2: shopState.shop.addressLine2,
            phone: shopState.shop.phoneNumber,
            footer: shopState.shop.footerText,
          ));
    }
  }

  void _showCashChangeDialog(
    BuildContext context,
    double totalAmount,
    String shiftId,
    String openedBy,
    ShopState shopState,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => CashChangeDialog(
        totalAmount: totalAmount,
        onComplete: () {
          Navigator.pop(ctx);
          _completeSale(context, shiftId, openedBy, 0, shopState);
        },
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
