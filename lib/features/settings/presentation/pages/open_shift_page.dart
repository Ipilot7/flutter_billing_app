import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:billing_app/features/settings/presentation/bloc/auth_flow_cubits.dart';
import 'package:billing_app/core/service_locator.dart';

class OpenShiftPage extends StatefulWidget {
  const OpenShiftPage({super.key});

  @override
  State<OpenShiftPage> createState() => _OpenShiftPageState();
}

class _OpenShiftPageState extends State<OpenShiftPage> {
  final _startBalanceController = TextEditingController(text: '100.00');
  late final OpenShiftCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<OpenShiftCubit>()..loadCurrentShift();
  }

  @override
  void dispose() {
    _startBalanceController.dispose();
    _cubit.close();
    super.dispose();
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
      child: BlocConsumer<OpenShiftCubit, OpenShiftState>(
        listener: (context, state) {
          if (state.error != null) {
            _showMessage(state.error!, isError: true);
          } else if (state.message != null) {
            _showMessage(state.message!);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Открытие смены')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  state.currentShiftId == null
                      ? 'Текущая смена: нет открытой'
                      : 'Текущая смена: ${state.currentShiftId}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _startBalanceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Стартовый баланс'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.loading
                      ? null
                      : () => context.read<OpenShiftCubit>().openShift(
                            startBalance: _startBalanceController.text,
                          ),
                  child: state.loading
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
        },
      ),
    );
  }
}
