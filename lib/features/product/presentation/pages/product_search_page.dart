import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_state.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/search_product_card.dart';
import 'package:billing_app/l10n/app_localizations.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  final ValueNotifier<int> _uiTick = ValueNotifier<int>(0);

  void _refreshUi() => _uiTick.value++;

  @override
  void initState() {
    super.initState();
    // Load products when page opens
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _uiTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _uiTick,
      builder: (_, __, ___) => Scaffold(
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchProducts,
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              _searchQuery = value.toLowerCase();
              _refreshUi();
            },
          ),
          actions: [
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchQuery = '';
                  _refreshUi();
                },
              ),
          ],
        ),
        body: Column(
          children: [
            _buildCategoryFilter(),
            Expanded(child: _buildProductGrid()),
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
          margin: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildProductGrid() {
    final l = AppLocalizations.of(context)!;
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
          return Center(child: Text(l.noProductsMatch));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return SearchProductCard(
              product: product,
              onTap: () {
                context.read<BillingBloc>().add(ScanBarcodeEvent(product.barcode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.productAddedToCart(product.name)),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
