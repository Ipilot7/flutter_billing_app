import 'package:flutter/material.dart';

import 'package:billing_app/core/network/backend_v1_client.dart';
import 'package:billing_app/core/network/backend_session.dart';
import 'package:billing_app/core/service_locator.dart';

class CashRegisterSetupPage extends StatefulWidget {
  const CashRegisterSetupPage({super.key});

  @override
  State<CashRegisterSetupPage> createState() => _CashRegisterSetupPageState();
}

class _CashRegisterSetupPageState extends State<CashRegisterSetupPage> {
  final _storeIdController = TextEditingController();
  final _terminalNameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _cashierUserController = TextEditingController();
  final _cashierPassController = TextEditingController();
  final _cashierPinController = TextEditingController();

  bool _loading = false;

  BackendV1Client get _client => sl<BackendV1Client>();
  BackendSession get _session => sl<BackendSession>();

  @override
  void initState() {
    super.initState();
    _prefillStoreId();
  }

  Future<void> _prefillStoreId() async {
    final storeId = await _session.getStoreId();
    if (!mounted || storeId == null) return;
    _storeIdController.text = storeId.toString();
  }

  @override
  void dispose() {
    _storeIdController.dispose();
    _terminalNameController.dispose();
    _deviceIdController.dispose();
    _cashierUserController.dispose();
    _cashierPassController.dispose();
    _cashierPinController.dispose();
    super.dispose();
  }

  Future<void> _registerCashRegister() async {
    final storeId = int.tryParse(_storeIdController.text.trim());
    if (storeId == null ||
        _terminalNameController.text.trim().isEmpty ||
        _deviceIdController.text.trim().isEmpty ||
        _cashierUserController.text.trim().isEmpty ||
        _cashierPassController.text.trim().length < 8 ||
        _cashierPinController.text.trim().isEmpty) {
      _showMessage(
        'Заполните все поля. Пароль кассира должен быть не менее 8 символов.',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _client.registerCashRegister(
        storeId: storeId,
        terminalName: _terminalNameController.text.trim(),
        deviceId: _deviceIdController.text.trim(),
        cashierUsername: _cashierUserController.text.trim(),
        cashierPassword: _cashierPassController.text,
        cashierPin: _cashierPinController.text.trim(),
      );
      _showMessage('Касса и кассир зарегистрированы.');
    } catch (e) {
      _showMessage('Ошибка регистрации кассы: $e', isError: true);
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
      appBar: AppBar(title: const Text('Добавление кассы/кассира')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Шаг setup: добавить terminal и кассира с PIN',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _storeIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Store ID'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _terminalNameController,
            decoration: const InputDecoration(labelText: 'Название кассы'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _deviceIdController,
            decoration: const InputDecoration(labelText: 'Device ID'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cashierUserController,
            decoration: const InputDecoration(labelText: 'Логин кассира'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cashierPassController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Пароль кассира'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cashierPinController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'PIN кассира'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _registerCashRegister,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Добавить кассу и кассира'),
          ),
        ],
      ),
    );
  }
}
