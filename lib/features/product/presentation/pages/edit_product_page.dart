import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import '../../../measurement_unit/presentation/bloc/unit_bloc.dart';
import '../../../measurement_unit/presentation/bloc/unit_event.dart';
import '../widgets/unit_selector.dart';
import '../widgets/category_selector.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<int> _uiTick = ValueNotifier<int>(0);
  late String _name;
  late double _price;
  late double _costPrice;
  late double _stock;
  late String _unit;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
    _costPrice = widget.product.costPrice;
    _stock = widget.product.stock;
    _unit = widget.product.unit;
    _categoryId = widget.product.categoryId;
    context.read<UnitBloc>().add(LoadUnitsEvent());
  }

  @override
  void dispose() {
    _uiTick.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        barcode: widget.product.barcode,
        price: _price,
        costPrice: _costPrice,
        unit: _unit,
        stock: _stock,
        categoryId: _categoryId,
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return ValueListenableBuilder<int>(
      valueListenable: _uiTick,
      builder: (_, __, ___) => Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 32, color: Theme.of(context).primaryColor),
              onPressed: () => context.pop(),
            ),
            title: Text(l.editProduct,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Barcode details (immutable block)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppTheme.primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code_scanner,
                              color: AppTheme.primaryColor, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.barcode.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.7))),
                              const SizedBox(height: 2),
                              Text(widget.product.barcode,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    InputLabel(text: l.productName),
                    TextFormField(
                      initialValue: _name,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => value == null || value.isEmpty
                          ? l.pleaseEnterName
                          : null,
                      onSaved: (value) => _name = value!,
                    ),
                    const SizedBox(height: 24),

                    InputLabel(text: l.price),
                    TextFormField(
                      initialValue: _price.toStringAsFixed(2),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: '${l.currency} ',
                        prefixStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? l.pleaseEnterPrice
                          : null,
                      onSaved: (value) =>
                          _price = double.tryParse(value ?? '0') ?? 0.0,
                    ),
                    const SizedBox(height: 24),

                    InputLabel(text: l.costPrice),
                    TextFormField(
                      initialValue: _costPrice.toStringAsFixed(2),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: '${l.currency} ',
                        prefixStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      onSaved: (value) =>
                          _costPrice = double.tryParse(value ?? '0') ?? 0.0,
                    ),
                    const SizedBox(height: 24),

                    InputLabel(text: l.stock),
                    TextFormField(
                      initialValue: _stock % 1 == 0
                          ? _stock.toInt().toString()
                          : _stock.toStringAsFixed(2),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onSaved: (value) =>
                          _stock = double.tryParse(value ?? '0') ?? 0.0,
                    ),
                    const SizedBox(height: 24),

                    InputLabel(text: l.measurementUnit),
                    UnitSelector(
                      selectedUnit: _unit,
                      onChanged: (val) {
                        _unit = val;
                        _uiTick.value++;
                      },
                    ),
                    const SizedBox(height: 24),

                    InputLabel(text: l.selectCategory),
                    CategorySelector(
                      selectedCategoryId: _categoryId,
                      onChanged: (val) {
                        _categoryId = val;
                        _uiTick.value++;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: PrimaryButton(
            onPressed: _submit,
            icon: Icons.save,
            label: l.saveChanges,
          )),
    );
  }
}
