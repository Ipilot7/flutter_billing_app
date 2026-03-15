import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:billing_app/features/settings/presentation/bloc/auth_flow_cubits.dart';
import 'package:billing_app/core/service_locator.dart';

class CashierLoginPage extends StatefulWidget {
  const CashierLoginPage({super.key});

  @override
  State<CashierLoginPage> createState() => _CashierLoginPageState();
}

class _CashierLoginPageState extends State<CashierLoginPage> {
  final _pinController = TextEditingController();

  late final CashierLoginCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<CashierLoginCubit>()..loadStartupState();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _showDeviceQr(String deviceId) async {
    if (deviceId.trim().isEmpty) {
      await _cubit.refreshDeviceId();
      return;
    }
    context.push('/cashier-device-qr', extra: deviceId);
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
      child: BlocConsumer<CashierLoginCubit, CashierLoginState>(
        listener: (context, state) {
          if (state.error != null) {
            _showMessage(state.error!, isError: true);
          } else if (state.message != null) {
            _showMessage(state.message!);
          }
          if (state.navigateTo != null) {
            context.go(state.navigateTo!);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Вход кассира')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showDeviceQr(state.deviceId),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Показать QR устройства'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'PIN кассира'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.loading
                      ? null
                      : () => context.read<CashierLoginCubit>().login(
                            deviceId: state.deviceId,
                            pin: _pinController.text,
                          ),
                  child: state.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Войти'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/owner-login'),
                  child: const Text('Вход владельца'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
