import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/billing_bloc.dart';
import 'cart_item_card.dart';
import 'empty_cart_view.dart';
import 'today_stats_bar.dart';

class CartBottomPanel extends StatelessWidget {
  const CartBottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        children: [
          // Drag handle indicator
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Today's quick stats bar
          const TodayStatsBar(),
          
          BlocBuilder<BillingBloc, BillingState>(
            buildWhen: (previous, current) =>
                previous.cartItems != current.cartItems ||
                previous.globalDiscount != current.globalDiscount,
            builder: (context, state) {
              final totalItems = state.cartItems.fold<double>(0, (sum, i) => sum + i.quantity);
              final l = AppLocalizations.of(context)!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.scannedItems,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Text(l.totalItems(totalItems.toInt()),
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l.totalAmount.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.2)),
                        Text(
                          '${l.currency} ${state.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),

          // List View
          Expanded(
            child: BlocBuilder<BillingBloc, BillingState>(
              buildWhen: (previous, current) =>
                  previous.cartItems != current.cartItems,
              builder: (context, state) {
                if (state.cartItems.isEmpty) {
                  return const EmptyCartView();
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 16, bottom: 100),
                  itemCount: state.cartItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.cartItems[index];
                    return CartItemCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
