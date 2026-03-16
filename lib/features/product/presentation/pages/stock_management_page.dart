import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_state.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:billing_app/l10n/app_localizations.dart';

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  final ValueNotifier<int> _uiTick = ValueNotifier<int>(0);

  void _refreshUi() => _uiTick.value++;

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
        appBar: AppBar(
          title: Text(l.stockManagement,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l.searchProducts,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _searchQuery = value.toLowerCase();
                  _refreshUi();
                },
              ),
            ),
            _buildCategoryFilter(),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state.categories.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final category = isAll ? null : state.categories[index - 1];
              final isSelected = isAll
                  ? _selectedCategoryId == null
                  : _selectedCategoryId == category?.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(isAll
                      ? AppLocalizations.of(context)!.all
                      : category!.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    _selectedCategoryId = isAll ? null : category?.id;
                    _refreshUi();
                  },
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (previous, current) => previous.products != current.products,
      builder: (context, state) {
        final filteredProducts = state.products.where((p) {
          final matchesSearch = p.name.toLowerCase().contains(_searchQuery) ||
              p.barcode.contains(_searchQuery);
          final matchesCategory = _selectedCategoryId == null ||
              p.categoryId == _selectedCategoryId;
          return matchesSearch && matchesCategory;
        }).toList();

        if (filteredProducts.isEmpty) {
          return Center(
              child: Text(AppLocalizations.of(context)!.noProductsMatch));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProductBloc>().add(LoadProducts());
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredProducts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductItem(product);
            },
          ),
        );
      },
    );
  }

  Widget _buildProductItem(Product product) {
    final l = AppLocalizations.of(context)!;
    final isLowStock = product.stock <= 5;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(product.name,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.barcode,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Row(
            children: [
              Text('${l.currentStock}: ', style: const TextStyle(fontSize: 12)),
              Text(
                '${product.stock.toInt()} ${product.unit}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isLowStock ? Colors.red : Colors.green[700],
                ),
              ),
              if (isLowStock) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l.lowStock,
                    style: const TextStyle(color: Colors.red, fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          foregroundColor: AppTheme.primaryColor,
          elevation: 0,
        ),
        onPressed: () => _showUpdateStockDialog(product),
        child: Text(l.edit),
      ),
    );
  }

  void _showUpdateStockDialog(Product product) {
    final controller =
        TextEditingController(text: product.stock.toInt().toString());
    final l = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.updateStock),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.newStock,
                suffixText: product.unit,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = double.tryParse(controller.text);
              if (newStock != null) {
                context
                    .read<ProductBloc>()
                    .add(UpdateProduct(product.copyWith(stock: newStock)));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.stockUpdated),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
  }
}
