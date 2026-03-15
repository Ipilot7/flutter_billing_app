import 'package:flutter/material.dart';

import 'package:billing_app/core/network/backend_v1_client.dart';
import 'package:billing_app/core/network/backend_session.dart';
import 'package:billing_app/core/service_locator.dart';

class PlatformRegistrationPage extends StatefulWidget {
  const PlatformRegistrationPage({super.key});

  @override
  State<PlatformRegistrationPage> createState() =>
      _PlatformRegistrationPageState();
}

class _PlatformRegistrationPageState extends State<PlatformRegistrationPage> {
  final _orgController = TextEditingController();
  final _storeController = TextEditingController();
  final _ownerUserController = TextEditingController();
  final _ownerPassController = TextEditingController();

  bool _loading = false;

  BackendV1Client get _client => sl<BackendV1Client>();
  BackendSession get _session => sl<BackendSession>();

  @override
  void dispose() {
    _orgController.dispose();
    _storeController.dispose();
    _ownerUserController.dispose();
    _ownerPassController.dispose();
    super.dispose();
  }

  Future<void> _registerPlatform() async {
    if (_orgController.text.trim().isEmpty ||
        _storeController.text.trim().isEmpty ||
        _ownerUserController.text.trim().isEmpty ||
        _ownerPassController.text.trim().length < 8) {
      _showMessage(
        'Заполните все поля. Пароль владельца должен быть не менее 8 символов.',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final currentBaseUrl = await _session.getBaseUrl();
      if (currentBaseUrl == null || currentBaseUrl.trim().isEmpty) {
        await _session.saveBaseUrl('http://192.168.0.54:8000/');
      }
      final response = await _client.registerPlatform(
        organizationName: _orgController.text.trim(),
        storeName: _storeController.text.trim(),
        ownerUsername: _ownerUserController.text.trim(),
        ownerPassword: _ownerPassController.text,
      );

      final store = response['store'] as Map<String, dynamic>?;
      final storeId = store?['id'];
      _showMessage(
        storeId != null
            ? 'Платформа зарегистрирована. Store ID: $storeId'
            : 'Платформа зарегистрирована.',
      );
    } catch (e) {
      _showMessage('Ошибка регистрации: $e', isError: true);
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
      appBar: AppBar(title: const Text('Регистрация платформы')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Шаг owner: создать организацию и магазин',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _orgController,
            decoration:
                const InputDecoration(labelText: 'Название организации'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _storeController,
            decoration: const InputDecoration(labelText: 'Название магазина'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ownerUserController,
            decoration: const InputDecoration(labelText: 'Логин владельца'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ownerPassController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Пароль владельца'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _registerPlatform,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Зарегистрировать платформу'),
          ),
        ],
      ),
    );
  }
}
