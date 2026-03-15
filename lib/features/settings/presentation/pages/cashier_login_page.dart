import 'package:flutter/material.dart';

import 'package:billing_app/core/data/app_database.dart';
import 'package:billing_app/core/network/backend_v1_client.dart';
import 'package:billing_app/core/service_locator.dart';

class CashierLoginPage extends StatefulWidget {
  const CashierLoginPage({super.key});

  @override
  State<CashierLoginPage> createState() => _CashierLoginPageState();
}

class _CashierLoginPageState extends State<CashierLoginPage> {
  final _deviceIdController = TextEditingController();
  final _pinController = TextEditingController();

  bool _loading = false;

  BackendV1Client get _client => sl<BackendV1Client>();
  AppDatabase get _db => sl<AppDatabase>();

  @override
  void dispose() {
    _deviceIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_deviceIdController.text.trim().isEmpty ||
        _pinController.text.trim().isEmpty) {
      _showMessage('Введите device id и PIN.', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await _client.loginCashierTerminal(
        deviceId: _deviceIdController.text.trim(),
        cashierPin: _pinController.text.trim(),
      );

      final products = await _client.fetchProducts();
      for (final product in products) {
        final id = product['id']?.toString();
        final name = product['name']?.toString();
        final barcode = product['barcode']?.toString();
        if (id == null || name == null || barcode == null) {
          continue;
        }

        final price = double.tryParse(product['price'].toString()) ?? 0.0;
        final cost = double.tryParse(product['cost'].toString()) ?? 0.0;
        final stock = double.tryParse(product['stock'].toString()) ?? 0.0;

        await _db.upsertProduct(
          ProductTable(
            id: id,
            name: name,
            barcode: barcode,
            price: price,
            costPrice: cost,
            stock: stock,
            unit: 'шт',
            categoryId: null,
          ),
        );
      }

      _showMessage(
          'Вход успешен. Синхронизировано товаров: ${products.length}.');
    } catch (e) {
      _showMessage('Ошибка входа: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход кассира')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Шаг login: вход по terminal (device_id) + PIN',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _deviceIdController,
            decoration: const InputDecoration(labelText: 'Device ID'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pinController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'PIN кассира'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Войти'),
          ),
        ],
      ),
    );
  }
}
