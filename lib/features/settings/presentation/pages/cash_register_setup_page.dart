import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:billing_app/features/settings/presentation/bloc/auth_flow_cubits.dart';
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

  late final CashRegisterSetupCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<CashRegisterSetupCubit>()..prefillStoreId();
  }

  @override
  void dispose() {
    _storeIdController.dispose();
    _terminalNameController.dispose();
    _deviceIdController.dispose();
    _cashierUserController.dispose();
    _cashierPassController.dispose();
    _cashierPinController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _scanCashierQr() async {
    final raw = await context.push<String>('/scanner');
    if (!mounted || raw == null || raw.trim().isEmpty) return;
    context.read<CashRegisterSetupCubit>().applyScannedQr(raw.trim());
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
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<CashRegisterSetupCubit, CashRegisterSetupState>(
        listener: (context, state) {
          if (state.storeId.isNotEmpty && _storeIdController.text.isEmpty) {
            _storeIdController.text = state.storeId;
          }
          if (state.deviceId.isNotEmpty &&
              _deviceIdController.text != state.deviceId) {
            _deviceIdController.text = state.deviceId;
          }
          if (state.error != null) {
            _showMessage(state.error!, isError: true);
          } else if (state.message != null) {
            _showMessage(state.message!);
          }
        },
        builder: (context, state) {
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
                  decoration:
                      const InputDecoration(labelText: 'Название кассы'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _deviceIdController,
                  decoration: const InputDecoration(labelText: 'Device ID'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: state.loading ? null : _scanCashierQr,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Сканировать QR устройства кассира'),
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
                  decoration:
                      const InputDecoration(labelText: 'Пароль кассира'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cashierPinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'PIN кассира'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.loading
                      ? null
                      : () => context.read<CashRegisterSetupCubit>().register(
                            storeId: _storeIdController.text,
                            terminalName: _terminalNameController.text,
                            deviceId: _deviceIdController.text,
                            cashierUsername: _cashierUserController.text,
                            cashierPassword: _cashierPassController.text,
                            cashierPin: _cashierPinController.text,
                          ),
                  child: state.loading
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
        },
      ),
    );
  }
}
