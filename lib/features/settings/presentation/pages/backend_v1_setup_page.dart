import 'package:flutter/material.dart';

import 'package:billing_app/core/data/app_database.dart';
import 'package:billing_app/core/network/backend_session.dart';
import 'package:billing_app/core/network/backend_v1_client.dart';
import 'package:billing_app/core/service_locator.dart';

class BackendV1SetupPage extends StatefulWidget {
  const BackendV1SetupPage({super.key});

  @override
  State<BackendV1SetupPage> createState() => _BackendV1SetupPageState();
}

class _BackendV1SetupPageState extends State<BackendV1SetupPage> {
  final _baseUrlController = TextEditingController();

  final _orgController = TextEditingController();
  final _storeController = TextEditingController();
  final _ownerUserController = TextEditingController();
  final _ownerPassController = TextEditingController();

  final _cashStoreIdController = TextEditingController();
  final _terminalNameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _cashierUserController = TextEditingController();
  final _cashierPassController = TextEditingController();
  final _cashierPinController = TextEditingController();

  final _loginDeviceController = TextEditingController();
  final _loginPinController = TextEditingController();

  final _startBalanceController = TextEditingController(text: '100.00');

  bool _loading = false;
  String? _message;
  int _localProductCount = 0;
  int? _terminalId;
  int? _storeId;
  int? _organizationId;
  int? _shiftId;
  bool _hasToken = false;

  BackendV1Client get _client => sl<BackendV1Client>();
  BackendSession get _session => sl<BackendSession>();
  AppDatabase get _db => sl<AppDatabase>();

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final baseUrl = await _session.getBaseUrl();
    final token = await _session.getAccessToken();
    final terminalId = await _session.getTerminalId();
    final storeId = await _session.getStoreId();
    final organizationId = await _session.getOrganizationId();
    final shiftId = await _session.getCurrentShiftId();
    final productCount = await _db.countProducts();
    if (!mounted) return;
    setState(() {
      _baseUrlController.text = baseUrl ?? 'http://192.168.0.54:8000/';
      _message = null;
      _hasToken = token != null && token.isNotEmpty;
      _terminalId = terminalId;
      _storeId = storeId;
      _organizationId = organizationId;
      _shiftId = shiftId;
      _localProductCount = productCount;
    });
  }

  Future<void> _refreshStatus() async {
    final token = await _session.getAccessToken();
    final terminalId = await _session.getTerminalId();
    final storeId = await _session.getStoreId();
    final organizationId = await _session.getOrganizationId();
    final shiftId = await _session.getCurrentShiftId();
    final productCount = await _db.countProducts();
    if (!mounted) return;
    setState(() {
      _hasToken = token != null && token.isNotEmpty;
      _terminalId = terminalId;
      _storeId = storeId;
      _organizationId = organizationId;
      _shiftId = shiftId;
      _localProductCount = productCount;
    });
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _orgController.dispose();
    _storeController.dispose();
    _ownerUserController.dispose();
    _ownerPassController.dispose();
    _cashStoreIdController.dispose();
    _terminalNameController.dispose();
    _deviceIdController.dispose();
    _cashierUserController.dispose();
    _cashierPassController.dispose();
    _cashierPinController.dispose();
    _loginDeviceController.dispose();
    _loginPinController.dispose();
    _startBalanceController.dispose();
    super.dispose();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await action();
      await _refreshStatus();
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend V1 Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _sectionTitle('1) Backend URL'),
            TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://192.168.0.54:8000/',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() async {
                        await _session.saveBaseUrl(_baseUrlController.text);
                        setState(() {
                          _message = 'Base URL saved';
                        });
                      }),
              child: const Text('Save URL'),
            ),
            const SizedBox(height: 20),
            _sectionTitle('2) Register Platform (Owner)'),
            TextField(
              controller: _orgController,
              decoration: const InputDecoration(labelText: 'Organization name'),
            ),
            TextField(
              controller: _storeController,
              decoration: const InputDecoration(labelText: 'Store name'),
            ),
            TextField(
              controller: _ownerUserController,
              decoration: const InputDecoration(labelText: 'Owner username'),
            ),
            TextField(
              controller: _ownerPassController,
              decoration: const InputDecoration(labelText: 'Owner password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() async {
                        if (_orgController.text.trim().isEmpty ||
                            _storeController.text.trim().isEmpty ||
                            _ownerUserController.text.trim().isEmpty ||
                            _ownerPassController.text.trim().length < 8) {
                          throw Exception(
                              'Fill all platform fields. Password must be at least 8 chars.');
                        }
                        final response = await _client.registerPlatform(
                          organizationName: _orgController.text,
                          storeName: _storeController.text,
                          ownerUsername: _ownerUserController.text,
                          ownerPassword: _ownerPassController.text,
                        );
                        final store =
                            response['store'] as Map<String, dynamic>?;
                        if (store != null) {
                          _cashStoreIdController.text = store['id'].toString();
                        }
                        setState(() {
                          _message = 'Platform registered';
                        });
                      }),
              child: const Text('Register Platform'),
            ),
            const SizedBox(height: 20),
            _sectionTitle('3) Register Cash Register'),
            TextField(
              controller: _cashStoreIdController,
              decoration: const InputDecoration(labelText: 'Store ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _terminalNameController,
              decoration: const InputDecoration(labelText: 'Terminal name'),
            ),
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(labelText: 'Device ID'),
            ),
            TextField(
              controller: _cashierUserController,
              decoration: const InputDecoration(labelText: 'Cashier username'),
            ),
            TextField(
              controller: _cashierPassController,
              decoration: const InputDecoration(labelText: 'Cashier password'),
              obscureText: true,
            ),
            TextField(
              controller: _cashierPinController,
              decoration: const InputDecoration(labelText: 'Cashier PIN'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() async {
                        final storeId =
                            int.tryParse(_cashStoreIdController.text);
                        if (storeId == null ||
                            _terminalNameController.text.trim().isEmpty ||
                            _deviceIdController.text.trim().isEmpty ||
                            _cashierUserController.text.trim().isEmpty ||
                            _cashierPassController.text.trim().length < 8 ||
                            _cashierPinController.text.trim().isEmpty) {
                          throw Exception(
                              'Fill all cash register fields. Password must be at least 8 chars.');
                        }
                        await _client.registerCashRegister(
                          storeId: storeId,
                          terminalName: _terminalNameController.text,
                          deviceId: _deviceIdController.text,
                          cashierUsername: _cashierUserController.text,
                          cashierPassword: _cashierPassController.text,
                          cashierPin: _cashierPinController.text,
                        );
                        _loginDeviceController.text = _deviceIdController.text;
                        _loginPinController.text = _cashierPinController.text;
                        setState(() {
                          _message = 'Cash register registered';
                        });
                      }),
              child: const Text('Register Cash Register'),
            ),
            const SizedBox(height: 20),
            _sectionTitle('4) Cashier Login (Terminal + PIN)'),
            TextField(
              controller: _loginDeviceController,
              decoration: const InputDecoration(labelText: 'Device ID'),
            ),
            TextField(
              controller: _loginPinController,
              decoration: const InputDecoration(labelText: 'Cashier PIN'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() async {
                        if (_loginDeviceController.text.trim().isEmpty ||
                            _loginPinController.text.trim().isEmpty) {
                          throw Exception('Enter device id and cashier PIN.');
                        }
                        await _client.loginCashierTerminal(
                          deviceId: _loginDeviceController.text,
                          cashierPin: _loginPinController.text,
                        );
                        final products = await _client.fetchProducts();
                        for (final product in products) {
                          final id = product['id']?.toString();
                          final name = product['name']?.toString();
                          final barcode = product['barcode']?.toString();

                          if (id == null || name == null || barcode == null) {
                            continue;
                          }

                          final price =
                              double.tryParse(product['price'].toString()) ??
                                  0.0;
                          final cost =
                              double.tryParse(product['cost'].toString()) ??
                                  0.0;
                          final stock =
                              double.tryParse(product['stock'].toString()) ??
                                  0.0;

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
                        setState(() {
                          _message =
                              'Cashier login success. Auto-synced ${products.length} products.';
                        });
                      }),
              child: const Text('Login Cashier'),
            ),
            const SizedBox(height: 20),
            _sectionTitle('5) Open Shift'),
            TextField(
              controller: _startBalanceController,
              decoration: const InputDecoration(labelText: 'Start balance'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() async {
                        final startBalance =
                            double.tryParse(_startBalanceController.text);
                        if (startBalance == null || startBalance < 0) {
                          throw Exception(
                              'Start balance must be a valid non-negative number.');
                        }
                        await _client.openShift(
                          startBalance: startBalance,
                        );
                        setState(() {
                          _message = 'Shift opened and saved in session';
                        });
                      }),
              child: const Text('Open Shift'),
            ),
            const SizedBox(height: 20),
            _sectionTitle('6) Sync Catalog From Backend'),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() async {
                        final products = await _client.fetchProducts();

                        for (final product in products) {
                          final id = product['id']?.toString();
                          final name = product['name']?.toString();
                          final barcode = product['barcode']?.toString();

                          if (id == null || name == null || barcode == null) {
                            continue;
                          }

                          final price =
                              double.tryParse(product['price'].toString()) ??
                                  0.0;
                          final cost =
                              double.tryParse(product['cost'].toString()) ??
                                  0.0;
                          final stock =
                              double.tryParse(product['stock'].toString()) ??
                                  0.0;

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

                        setState(() {
                          _message =
                              'Synced ${products.length} products from backend';
                        });
                      }),
              child: const Text('Sync Products'),
            ),
            const SizedBox(height: 20),
            _sectionTitle('7) Session Maintenance'),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => _runAction(() async {
                        await _session.clearAuth();
                        setState(() {
                          _message = 'Backend session cleared';
                        });
                      }),
              child: const Text('Clear Backend Session'),
            ),
            const SizedBox(height: 16),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _message!.startsWith('Error')
                      ? Colors.red.withValues(alpha: 0.08)
                      : Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_message!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatusCard() {
    final baseConfigured = _baseUrlController.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backend Session Status',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text('Base URL: ${baseConfigured ? 'configured' : 'not set'}'),
          Text('Authenticated: ${_hasToken ? 'yes' : 'no'}'),
          Text('Organization ID: ${_organizationId ?? '-'}'),
          Text('Store ID: ${_storeId ?? '-'}'),
          Text('Terminal ID: ${_terminalId ?? '-'}'),
          Text('Current Shift ID: ${_shiftId ?? '-'}'),
          Text('Local products: $_localProductCount'),
        ],
      ),
    );
  }
}
