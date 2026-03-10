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
import '../../../measurement_unit/presentation/bloc/unit_state.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _barcode = '';
  double _price = 0.0;
  String _unit = '';

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

  void _scanBarcode() async {
    final result = await context.push<String>('/scanner');
    if (result != null && result.isNotEmpty) {
      setState(() {
        _barcode = result;
      });
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
        unit: _unit,
      );

      context.read<ProductBloc>().add(AddProduct(product));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          title: Text(AppLocalizations.of(context)!.addProduct,
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
                  InputLabel(text: AppLocalizations.of(context)!.barcode),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(_barcode),
                          initialValue: _barcode,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .scanOrEnterBarcode,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? AppLocalizations.of(context)!.enterBarcode
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
                  Text(AppLocalizations.of(context)!.scanIconHint,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4C669A))),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  InputLabel(text: AppLocalizations.of(context)!.productName),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.namePlaceholder,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value == null || value.isEmpty
                        ? AppLocalizations.of(context)!.pleaseEnterName
                        : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  InputLabel(text: AppLocalizations.of(context)!.price),
                  TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.pricePlaceholder,
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
                              value: _unit,
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
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.add_circle,
          label: AppLocalizations.of(context)!.addProduct,
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
