import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import '../../../measurement_unit/presentation/bloc/unit_bloc.dart';
import '../../../measurement_unit/presentation/bloc/unit_event.dart';
import '../widgets/unit_selector.dart';
import '../widgets/category_selector.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<int> _uiTick = ValueNotifier<int>(0);
  String _name = '';
  String _barcode = '';
  double _price = 0.0;
  double _costPrice = 0.0;
  double _stock = 0.0;
  String _unit = '';
  String? _categoryId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_unit.isEmpty) {
      _unit = AppLocalizations.of(context)!.unitDefault;
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<UnitBloc>().add(LoadUnitsEvent());
  }

  @override
  void dispose() {
    _uiTick.dispose();
    super.dispose();
  }

  void _scanBarcode() async {
    final result = await context.push<String>('/scanner');
    if (result != null && result.isNotEmpty) {
      _barcode = result;
      _uiTick.value++;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productState = context.read<ProductBloc>().state;
      final existingProduct =
          productState.products.where((p) => p.barcode == _barcode).firstOrNull;

      if (existingProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.barcodeExists(_barcode)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final product = Product(
        id: const Uuid().v4(),
        name: _name,
        barcode: _barcode,
        price: _price,
        costPrice: _costPrice,
        stock: _stock,
        unit: _unit,
        categoryId: _categoryId,
      );

      context.read<ProductBloc>().add(AddProduct(product));
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 28, color: Theme.of(context).primaryColor),
              onPressed: () => context.pop(),
            ),
            title: Text(l.addProduct,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputLabel(text: l.barcode),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey(_barcode),
                            initialValue: _barcode,
                            decoration: InputDecoration(
                              hintText: l.scanOrEnterBarcode,
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? l.enterBarcode
                                : null,
                            onSaved: (value) => _barcode = value!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.qr_code_scanner,
                                color: AppTheme.primaryColor),
                            onPressed: _scanBarcode,
                            padding: const EdgeInsets.all(14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(l.scanIconHint,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF4C669A))),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                    InputLabel(text: l.productName),
                    TextFormField(
                      decoration: InputDecoration(hintText: l.namePlaceholder),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => value == null || value.isEmpty
                          ? l.pleaseEnterName
                          : null,
                      onSaved: (value) => _name = value!,
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                    InputLabel(text: l.price),
                    TextFormField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: l.pricePlaceholder,
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: l.pricePlaceholder,
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: '0'),
                      onSaved: (value) =>
                          _stock = double.tryParse(value ?? '0') ?? 0.0,
                    ),
                    const SizedBox(height: 24),
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
            icon: Icons.add_circle,
            label: l.addProduct,
          )),
    );
  }
}
