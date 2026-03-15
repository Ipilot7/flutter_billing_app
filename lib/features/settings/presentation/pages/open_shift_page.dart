import 'package:flutter/material.dart';

import 'package:billing_app/core/network/backend_v1_client.dart';
import 'package:billing_app/core/network/backend_session.dart';
import 'package:billing_app/core/service_locator.dart';

class OpenShiftPage extends StatefulWidget {
  const OpenShiftPage({super.key});

  @override
  State<OpenShiftPage> createState() => _OpenShiftPageState();
}

class _OpenShiftPageState extends State<OpenShiftPage> {
  final _startBalanceController = TextEditingController(text: '100.00');

  bool _loading = false;
  int? _currentShiftId;

  BackendV1Client get _client => sl<BackendV1Client>();
  BackendSession get _session => sl<BackendSession>();

  @override
  void initState() {
    super.initState();
    _loadCurrentShift();
  }

  Future<void> _loadCurrentShift() async {
    final shiftId = await _session.getCurrentShiftId();
    if (!mounted) return;
    setState(() => _currentShiftId = shiftId);
  }

  @override
  void dispose() {
    _startBalanceController.dispose();
    super.dispose();
  }

  Future<void> _openShift() async {
    final startBalance = double.tryParse(_startBalanceController.text.trim());
    if (startBalance == null || startBalance < 0) {
      _showMessage('Введите корректный стартовый баланс.', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await _client.openShift(startBalance: startBalance);
      final shiftId = response['id'];
      await _loadCurrentShift();
      _showMessage(shiftId != null
          ? 'Смена открыта. Shift ID: $shiftId'
          : 'Смена открыта.');
    } catch (e) {
      _showMessage('Ошибка открытия смены: $e', isError: true);
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
      appBar: AppBar(title: const Text('Открытие смены')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _currentShiftId == null
                ? 'Текущая смена: нет открытой'
                : 'Текущая смена: $_currentShiftId',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _startBalanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Стартовый баланс'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _openShift,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Открыть смену'),
          ),
        ],
      ),
    );
  }
}
