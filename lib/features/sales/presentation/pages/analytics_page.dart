import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:billing_app/l10n/app_localizations.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import '../bloc/analytics_bloc.dart';
import '../widgets/stat_card.dart';
import '../widgets/transactions_summary_card.dart';
import '../widgets/by_category_chart.dart';
import '../widgets/daily_revenue_chart.dart';
import '../widgets/payment_pie_chart.dart';
import '../widgets/top_products_list.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedPeriod = 0; // 0: today, 1: week, 2: month
  DateTime _selectedDate = DateTime.now();
  final ValueNotifier<int> _uiTick = ValueNotifier<int>(0);

  void _refreshUi() => _uiTick.value++;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    DateTime from;
    DateTime to;

    switch (_selectedPeriod) {
      case 0: // Today
        from = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        to = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
        break;
      case 1: // Last 7 Days
        from = _selectedDate.subtract(const Duration(days: 7));
        to = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
        break;
      case 2: // Specific Month
        from = DateTime(_selectedDate.year, _selectedDate.month, 1);
        to = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
        break;
      default:
        from = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        to = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
    }

    context.read<AnalyticsBloc>().add(LoadAnalyticsEvent(from: from, to: to));
  }

  @override
  void dispose() {
    _uiTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ValueListenableBuilder<int>(
      valueListenable: _uiTick,
      builder: (_, __, ___) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(l.analytics,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildPeriodSelector(),
            Expanded(
              child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                builder: (context, state) {
                  if (state is AnalyticsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AnalyticsError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is AnalyticsLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _loadData();
                      },
                      child: _buildDashboard(state),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final l = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _periodChip(0, l.today),
          const SizedBox(width: 8),
          _periodChip(1, l.thisWeek),
          const SizedBox(width: 8),
          _periodChip(2, _selectedPeriod == 2 
            ? DateFormat('MMM yyyy').format(_selectedDate)
            : l.thisMonth),
          if (_selectedPeriod == 2) ...[
            const Spacer(),
            TextButton.icon(
              onPressed: _selectMonth,
              icon: const Icon(Icons.calendar_month, size: 18),
              label: Text(l.changeBtn),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      _refreshUi();
      _loadData();
    }
  }

  Widget _periodChip(int index, String label) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _selectedPeriod = index;
          _refreshUi();
          _loadData();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(AnalyticsLoaded state) {
    final l = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stat cards
        Row(
          children: [
            StatCard(
              title: l.revenue,
              value: state.totalRevenue,
              color: AppTheme.primaryColor,
              icon: Icons.trending_up_rounded,
            ),
            const SizedBox(width: 12),
            StatCard(
              title: l.profit,
              value: state.totalProfit,
              color: Colors.green,
              icon: Icons.attach_money_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Transactions count card
        TransactionsSummaryCard(state: state),
        const SizedBox(height: 20),

        // Daily Revenue chart (only for week/month)
        if (_selectedPeriod != 0 && state.sales.isNotEmpty) ...[
          _buildSectionTitle(l.dailyRevenue),
          const SizedBox(height: 12),
          DailyRevenueChart(sales: state.sales),
          const SizedBox(height: 24),
        ],

        // Payment breakdown
        _buildSectionTitle(l.salesByPayment),
        const SizedBox(height: 12),
        PaymentPieChart(state: state),
        const SizedBox(height: 24),

        // Category breakdown
        _buildSectionTitle(l.salesByCategory),
        const SizedBox(height: 12),
        ByCategoryChart(state: state),
        const SizedBox(height: 24),

        // Top products
        _buildSectionTitle(l.topProducts),
        const SizedBox(height: 12),
        TopProductsList(state: state),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
  }
}
