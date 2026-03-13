import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';
import 'package:billing_app/features/sales/presentation/bloc/sales_bloc.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:billing_app/features/sales/presentation/bloc/sales_event.dart';
import 'package:billing_app/features/sales/presentation/bloc/sales_state.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  int _filterPayment = -1; // -1 = all, 0=cash, 1=card, 2=terminal

  @override
  void initState() {
    super.initState();
    context.read<SalesBloc>().add(const LoadSalesHistoryEvent());
  }

  List<Sale> _filterSales(List<Sale> sales) {
    return sales.where((s) {
      if (_fromDate != null && s.createdAt.isBefore(_fromDate!)) return false;
      if (_toDate != null &&
          s.createdAt.isAfter(_toDate!.add(const Duration(days: 1)))) {
        return false;
      }
      if (_filterPayment != -1 && s.paymentType != _filterPayment) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _showDateRangePicker() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (range != null) {
      setState(() {
        _fromDate = range.start;
        _toDate = range.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _filterPayment = -1;
    });
  }

  Future<void> _exportToCSV(List<Sale> filteredSales) async {
    final l = AppLocalizations.of(context)!;

    List<List<dynamic>> rows = [];

    // Headers
    rows.add([
      "ID",
      "Date",
      "Items Count",
      "Total Amount",
      "Payment Method",
      "Opened By"
    ]);

    for (var sale in filteredSales) {
      String paymentMethod = sale.paymentType == 0
          ? "Cash"
          : sale.paymentType == 1
              ? "Card"
              : "Terminal";
      rows.add([
        sale.id,
        DateFormat('dd.MM.yyyy HH:mm').format(sale.createdAt),
        sale.items.length,
        sale.totalAmount,
        paymentMethod,
        sale.openedBy
      ]);
    }

    String csv = excel.encoder.convert(rows);

    final directory = await getTemporaryDirectory();
    final path =
        "${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csv);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: l.salesReport,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd.MM.yy');
    final hasFilter =
        _fromDate != null || _toDate != null || _filterPayment != -1;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.salesHistory,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          BlocBuilder<SalesBloc, SalesState>(
            builder: (context, state) {
              if (state is SalesLoaded && state.sales.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: l.exportCSV,
                  onPressed: () => _exportToCSV(_filterSales(state.sales)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          if (hasFilter)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: 'Clear filters',
              onPressed: _clearFilters,
            ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.calendar_month_outlined),
                if (hasFilter)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showDateRangePicker,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Date range chip
                if (_fromDate != null || _toDate != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      avatar: const Icon(Icons.calendar_today,
                          size: 14, color: Colors.white),
                      label: Text(
                        _fromDate != null && _toDate != null
                            ? '${dateFormat.format(_fromDate!)} – ${dateFormat.format(_toDate!)}'
                            : _fromDate != null
                                ? '${l.dateLabel}: ${dateFormat.format(_fromDate!)}'
                                : '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      deleteIcon: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                      onDeleted: () => setState(() {
                        _fromDate = null;
                        _toDate = null;
                      }),
                    ),
                  ),
                // Payment filter chips
                _paymentChip(-1, l.all),
                const SizedBox(width: 8),
                _paymentChip(0, l.cash),
                const SizedBox(width: 8),
                _paymentChip(1, l.card),
                const SizedBox(width: 8),
                _paymentChip(2, l.terminal),
              ],
            ),
          ),
          const Divider(height: 1),
          // Sales list
          Expanded(
            child: BlocBuilder<SalesBloc, SalesState>(
              builder: (context, state) {
                if (state is SalesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SalesError) {
                  return Center(child: Text(state.message));
                }
                if (state is SalesLoaded) {
                  final filtered = _filterSales(state.sales);
                  if (filtered.isEmpty) {
                    return _buildEmpty(l);
                  }
                  // Summary header
                  final totalRevenue = filtered
                      .where((s) => !s.isReturned)
                      .fold<double>(0, (sum, s) => sum + s.totalAmount);
                  return Column(
                    children: [
                      _buildSummaryBar(l, filtered.length, totalRevenue),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _SaleListTile(sale: filtered[index]);
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentChip(int type, String label) {
    final isSelected = _filterPayment == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (v) => setState(() => _filterPayment = type),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? AppTheme.primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildSummaryBar(AppLocalizations l, int count, double total) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${l.transactions}: $count',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(
            '${l.currency} ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(l.noSales,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SaleListTile extends StatelessWidget {
  final Sale sale;

  const _SaleListTile({required this.sale});

  String _getPaymentTypeLabel(BuildContext context, int type) {
    final l = AppLocalizations.of(context)!;
    switch (type) {
      case 0:
        return l.cash;
      case 1:
        return l.card;
      case 2:
        return l.terminal;
      default:
        return l.unknown;
    }
  }

  IconData _getPaymentIcon(int type) {
    switch (type) {
      case 0:
        return Icons.money;
      case 1:
        return Icons.credit_card;
      case 2:
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isReturned = sale.isReturned;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isReturned
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.grey[200]!,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => _SaleDetailsDialog(sale: sale),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Payment icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isReturned
                      ? Colors.red.withValues(alpha: 0.1)
                      : AppTheme.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReturned ? Icons.undo : _getPaymentIcon(sale.paymentType),
                  size: 20,
                  color: isReturned ? Colors.red : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentTypeLabel(context, sale.paymentType),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(dateFormat.format(sale.createdAt),
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[500])),
                    Text(
                      '${sale.items.length} ${l.items}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              // Amount + return button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isReturned ? '- ' : ''}${l.currency} ${sale.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: isReturned ? Colors.red : Colors.black87,
                    ),
                  ),
                  if (!isReturned)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l.returnSale),
                            content: Text(l.confirmReturn),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(l.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<SalesBloc>()
                                      .add(ReturnSaleEvent(saleId: sale.id));
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                                child: Text(l.returnSale),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.undo, size: 11, color: Colors.red[400]),
                            const SizedBox(width: 2),
                            Text(l.returnSale,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.red[400])),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaleDetailsDialog extends StatelessWidget {
  final Sale sale;

  const _SaleDetailsDialog({required this.sale});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return AlertDialog(
      title: Text(l.saleDetails),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${l.dateLabel}: ${dateFormat.format(sale.createdAt)}'),
            Text(
                '${l.totalLabel}: ${l.currency} ${sale.totalAmount.toStringAsFixed(2)}'),
            const Divider(),
            Text('${l.items}:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text('${item.productName} x${item.quantity}')),
                      Text('${l.currency} ${item.total.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
      ],
    );
  }
}
