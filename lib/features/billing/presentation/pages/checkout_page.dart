import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../shift/presentation/bloc/shift_bloc.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    // Ensure shop details are loaded for printing
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

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
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 28, color: Theme.of(context).primaryColor),
              onPressed: () {
                context.read<BillingBloc>().add(ClearCartEvent());
                context.go('/');
              },
            ),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state.printSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.printSuccess),
                    backgroundColor: Colors.green));
              }
              if (state.cartItems.isEmpty && state.error == null) {
                // Return to home completely if sale is completed successfully
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.saleCompleted),
                    backgroundColor: Colors.green));
              }
            },
            builder: (context, billingState) {
              return BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, shopState) {
                String upiId = '';
                String shopName = 'Shop';

                if (shopState is ShopLoaded) {
                  upiId = shopState.shop.upiId;
                  shopName = shopState.shop.name;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          children: [
                            // Table
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Table(
                                  border: const TableBorder(
                                    horizontalInside:
                                        BorderSide(color: borderColor),
                                    bottom: BorderSide(color: borderColor),
                                  ),
                                  children: [
                                    // Header row
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        border: Border(
                                            bottom:
                                                BorderSide(color: borderColor)),
                                      ),
                                      children: [
                                        _buildHeaderCell(
                                            AppLocalizations.of(context)!
                                                .productName,
                                            TextAlign.left),
                                        _buildHeaderCell(
                                            AppLocalizations.of(context)!.price,
                                            TextAlign.right),
                                        _buildHeaderCell(
                                            AppLocalizations.of(context)!.total,
                                            TextAlign.right),
                                      ],
                                    ),
                                    // Items rows
                                    ...billingState.cartItems.map((item) {
                                      return TableRow(
                                        children: [
                                          _buildDataCell(
                                            '${item.quantity} x ${item.product.name}',
                                            TextAlign.left,
                                          ),
                                          _buildDataCell(
                                              '${AppLocalizations.of(context)!.currency} ${item.product.price.toStringAsFixed(2)}',
                                              TextAlign.right,
                                              isSubtitle: true),
                                          _buildDataCell(
                                              '${AppLocalizations.of(context)!.currency} ${item.total.toStringAsFixed(2)}',
                                              TextAlign.right,
                                              isBold: true),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            const SizedBox(
                                height: 120), // padding for bottom fixed bar
                          ],
                        ),
                      ),
                    ),

                    // Bottom Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(24),
                            right: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                upiId.isNotEmpty
                                    ? Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .scanToPay,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: 180,
                                            height: 180,
                                            child: PrettyQrView.data(
                                              data:
                                                  'upi://pay?pa=$upiId&pn=$shopName&am=${billingState.totalAmount.toStringAsFixed(2)}&cu=INR',
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.grandTotal,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[400],
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Text(
                                      '${AppLocalizations.of(context)!.currency} ${billingState.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PrimaryButton(
                            onPressed: billingState.cartItems.isEmpty
                                ? null
                                : () {
                                    _showPaymentDialog(
                                        context, billingState, shopState);
                                  },
                            label: AppLocalizations.of(context)!.completeSale,
                            icon: Icons.check_circle,
                          ),
                          TextButton.icon(
                            onPressed: () {
                              if (shopState is ShopLoaded) {
                                context.read<BillingBloc>().add(
                                    PrintReceiptEvent(
                                        shopName: shopState.shop.name,
                                        address1: shopState.shop.addressLine1,
                                        address2: shopState.shop.addressLine2,
                                        phone: shopState.shop.phoneNumber,
                                        footer: shopState.shop.footerText));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            AppLocalizations.of(context)!
                                                .shopDetailsNotLoaded),
                                        backgroundColor: Colors.red));
                              }
                            },
                            icon: const Icon(Icons.print),
                            label: Text(
                                AppLocalizations.of(context)!.printReceiptOnly,
                                style: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ));
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }

  void _showPaymentDialog(
      BuildContext context, BillingState billingState, ShopState shopState) {
    int paymentType = 0; // 0 cash, 1 card, 2 term

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (stCtx, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.paymentMethod),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<int>(
                    title: Text(AppLocalizations.of(context)!.cash),
                    value: 0,
                    groupValue: paymentType,
                    onChanged: (val) => setState(() => paymentType = val!),
                  ),
                  RadioListTile<int>(
                    title: Text(AppLocalizations.of(context)!.card),
                    value: 1,
                    groupValue: paymentType,
                    onChanged: (val) => setState(() => paymentType = val!),
                  ),
                  RadioListTile<int>(
                    title: Text(AppLocalizations.of(context)!.terminal),
                    value: 2,
                    groupValue: paymentType,
                    onChanged: (val) => setState(() => paymentType = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final shiftBloc = context.read<ShiftBloc>();
                    final currentShift = shiftBloc.currentShift;
                    if (currentShift == null) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.pleaseOpenShift),
                          backgroundColor: Colors.red));
                      return;
                    }

                    // Dispatch Sale
                    context.read<BillingBloc>().add(
                          CompleteSaleEvent(
                            shiftId: currentShift.id,
                            openedBy: currentShift.openedBy,
                            paymentType: paymentType,
                          ),
                        );

                    // Also print receipt? Auto print?
                    if (shopState is ShopLoaded) {
                      context.read<BillingBloc>().add(
                            PrintReceiptEvent(
                                shopName: shopState.shop.name,
                                address1: shopState.shop.addressLine1,
                                address2: shopState.shop.addressLine2,
                                phone: shopState.shop.phoneNumber,
                                footer: shopState.shop.footerText),
                          );
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(AppLocalizations.of(context)!.checkout),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
