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
import '../../../measurement_unit/presentation/bloc/unit_state.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_state.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
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
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 32, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          title: Text(AppLocalizations.of(context)!.editProduct,
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
                          color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner,
                            color: AppTheme.primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                AppLocalizations.of(context)!
                                    .barcode
                                    .toUpperCase(),
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

                  InputLabel(text: AppLocalizations.of(context)!.productName),

                  TextFormField(
                    initialValue: _name,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value == null || value.isEmpty
                        ? AppLocalizations.of(context)!.pleaseEnterName
                        : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),

                  InputLabel(text: AppLocalizations.of(context)!.price),

                  TextFormField(
                    initialValue: _price.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '${AppLocalizations.of(context)!.currency} ',
                      prefixStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? AppLocalizations.of(context)!.pleaseEnterPrice
                        : null,
                    onSaved: (value) => _price = double.parse(value!),
                  ),
                  const SizedBox(height: 24),

                  InputLabel(text: AppLocalizations.of(context)!.costPrice),

                  TextFormField(
                    initialValue: _costPrice.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '${AppLocalizations.of(context)!.currency} ',
                      prefixStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    onSaved: (value) => _costPrice = double.parse(value ?? '0'),
                  ),
                  const SizedBox(height: 24),

                  InputLabel(text: AppLocalizations.of(context)!.stock),

                  TextFormField(
                    initialValue: _stock % 1 == 0
                        ? _stock.toInt().toString()
                        : _stock.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) => _stock = double.parse(value ?? '0'),
                  ),
                  const SizedBox(height: 24),
                  InputLabel(
                      text: AppLocalizations.of(context)!.measurementUnit),
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<UnitBloc, UnitState>(
                          builder: (context, state) {
                            List<String> units = [
                              AppLocalizations.of(context)!.unitDefault
                            ];
                            if (state is UnitLoaded) {
                              units =
                                  state.units.map((u) => u.shortName).toList();
                              if (!units.contains(
                                  AppLocalizations.of(context)!.unitDefault)) {
                                units.insert(0,
                                    AppLocalizations.of(context)!.unitDefault);
                              }
                            }

                            if (!units.contains(_unit)) {
                              _unit = units.first;
                            }

                            return DropdownButtonFormField<String>(
                              initialValue: _unit,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              items: units
                                  .map((u) => DropdownMenuItem(
                                      value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (val) => setState(() => _unit = val!),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add,
                              color: AppTheme.primaryColor),
                          onPressed: () => _showAddUnitDialog(context),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  InputLabel(
                      text: AppLocalizations.of(context)!.selectCategory),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      return DropdownButtonFormField<String>(
                        initialValue: _categoryId,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        hint:
                            Text(AppLocalizations.of(context)!.selectCategory),
                        items: state.categories
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _categoryId = val),
                      );
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
          label: AppLocalizations.of(context)!.saveChanges,
        ));
  }

  void _showAddUnitDialog(BuildContext context) {
    final nameController = TextEditingController();
    final shortNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addUnit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.unitNameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: shortNameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.unitShortNameLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  shortNameController.text.isNotEmpty) {
                context.read<UnitBloc>().add(AddUnitEvent(
                      name: nameController.text,
                      shortName: shortNameController.text,
                    ));
                Navigator.pop(ctx);
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }
}
