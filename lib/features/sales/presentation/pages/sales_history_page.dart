import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';
import 'package:billing_app/features/sales/presentation/bloc/sales_bloc.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:billing_app/features/sales/presentation/bloc/sales_event.dart';
import 'package:billing_app/features/sales/presentation/bloc/sales_state.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Refresh sales history when page is opened
    context.read<SalesBloc>().add(const LoadSalesHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.salesHistory),
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SalesError) {
            return Center(child: Text(state.message));
          }
          if (state is SalesLoaded) {
            if (state.sales.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noSales));
            }
            // Sort by date descending (newest first)
            final sortedSales = List<Sale>.from(state.sales)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sortedSales.length,
              itemBuilder: (context, index) {
                final sale = sortedSales[index];
                return _SaleListTile(sale: sale);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _SaleListTile extends StatelessWidget {
  final Sale sale;

  const _SaleListTile({required this.sale});

  String _getPaymentTypeLabel(BuildContext context, int type) {
    switch (type) {
      case 0:
        return AppLocalizations.of(context)!.cash;
      case 1:
        return AppLocalizations.of(context)!.card;
      case 2:
        return AppLocalizations.of(context)!.terminal;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          sale.isReturned ? Icons.undo : Icons.receipt,
          color: sale.isReturned ? Colors.red : Colors.green,
        ),
        title: Text(
          '${AppLocalizations.of(context)!.currency} ${sale.totalAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: sale.isReturned ? Colors.red : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(sale.createdAt)),
            Text(
              _getPaymentTypeLabel(context, sale.paymentType),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: sale.isReturned
            ? null
            : IconButton(
                icon: const Icon(Icons.undo, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.returnSale),
                      content:
                          Text(AppLocalizations.of(context)!.confirmReturn),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<SalesBloc>()
                                .add(ReturnSaleEvent(saleId: sale.id));
                            Navigator.pop(ctx);
                          },
                          child: Text(AppLocalizations.of(context)!.returnSale),
                        ),
                      ],
                    ),
                  );
                },
              ),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => _SaleDetailsDialog(sale: sale),
          );
        },
      ),
    );
  }
}

class _SaleDetailsDialog extends StatelessWidget {
  final Sale sale;

  const _SaleDetailsDialog({required this.sale});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.saleDetails),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${AppLocalizations.of(context)!.dateLabel}: ${dateFormat.format(sale.createdAt)}'),
            Text(
                '${AppLocalizations.of(context)!.totalLabel}: ${AppLocalizations.of(context)!.currency} ${sale.totalAmount.toStringAsFixed(2)}'),
            const Divider(),
            Text('${AppLocalizations.of(context)!.items}:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text('${item.productName} x${item.quantity}')),
                      Text(
                          '${AppLocalizations.of(context)!.currency} ${item.total.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }
}
