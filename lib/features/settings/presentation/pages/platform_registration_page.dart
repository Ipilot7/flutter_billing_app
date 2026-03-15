import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:billing_app/features/settings/presentation/bloc/auth_flow_cubits.dart';
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

  late final PlatformRegistrationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<PlatformRegistrationCubit>();
  }

  @override
  void dispose() {
    _orgController.dispose();
    _storeController.dispose();
    _ownerUserController.dispose();
    _ownerPassController.dispose();
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
      child: BlocConsumer<PlatformRegistrationCubit, PlatformRegistrationState>(
        listener: (context, state) {
          if (state.error != null) {
            _showMessage(state.error!, isError: true);
          } else if (state.message != null) {
            _showMessage(state.message!);
          }
        },
        builder: (context, state) {
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
                  decoration:
                      const InputDecoration(labelText: 'Название магазина'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ownerUserController,
                  decoration:
                      const InputDecoration(labelText: 'Логин владельца'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ownerPassController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Пароль владельца'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.loading
                      ? null
                      : () =>
                          context.read<PlatformRegistrationCubit>().register(
                                organizationName: _orgController.text,
                                storeName: _storeController.text,
                                ownerUsername: _ownerUserController.text,
                                ownerPassword: _ownerPassController.text,
                              ),
                  child: state.loading
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
        },
      ),
    );
  }
}
