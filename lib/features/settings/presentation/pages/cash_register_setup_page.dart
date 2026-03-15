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
  final _terminalNameController = TextEditingController();
  final _cashierUserController = TextEditingController();
  final _cashierPassController = TextEditingController();
  final _cashierPinController = TextEditingController();

  late final CashRegisterSetupCubit _cubit;

  @override
  void initState() {
    super.initState();
    _terminalNameController.text = 'Касса';
    _cubit = sl<CashRegisterSetupCubit>()..prefillStoreId();
  }

  @override
  void dispose() {
    _terminalNameController.dispose();
    _cashierUserController.dispose();
    _cashierPassController.dispose();
    _cashierPinController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _scanCashierQr() async {
    final raw = await context.push<String>('/scanner');
    if (!mounted || raw == null || raw.trim().isEmpty) return;
    _cubit.applyScannedQr(raw.trim());
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
          if (state.error != null) {
            _showMessage(state.error!, isError: true);
          } else if (state.registrationCompleted) {
            if (mounted) {
              if (context.canPop()) {
                context.pop(true);
              } else {
                context.go('/settings/cash-registers');
              }
            }
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
                  'Добавление кассы: отсканируйте QR устройства и укажите данные кассира',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('QR устройства кассира'),
                  subtitle: Text(state.deviceId.isEmpty
                      ? 'Не отсканирован'
                      : 'QR успешно отсканирован'),
                  trailing: Icon(
                    state.deviceId.isEmpty
                        ? Icons.qr_code_2_outlined
                        : Icons.check_circle,
                    color: state.deviceId.isEmpty ? Colors.grey : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: state.loading ? null : _scanCashierQr,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Сканировать QR устройства кассира'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _terminalNameController,
                  decoration:
                      const InputDecoration(labelText: 'Название кассы'),
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
                      : () => _cubit.register(
                            terminalName: _terminalNameController.text,
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
