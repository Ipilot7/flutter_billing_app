import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:billing_app/features/settings/presentation/bloc/auth_flow_cubits.dart';
import 'package:billing_app/core/service_locator.dart';

class OwnerLoginPage extends StatefulWidget {
  const OwnerLoginPage({super.key});

  @override
  State<OwnerLoginPage> createState() => _OwnerLoginPageState();
}

class _OwnerLoginPageState extends State<OwnerLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OwnerLoginCubit>(),
      child: BlocConsumer<OwnerLoginCubit, OwnerLoginState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.error!), backgroundColor: Colors.red),
            );
          } else if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message!), backgroundColor: Colors.green),
            );
          }

          if (state.navigateTo != null) {
            context.go(state.navigateTo!);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Вход владельца')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Owner login: вход по username/password',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.loading
                      ? null
                      : () => context.read<OwnerLoginCubit>().login(
                            username: _usernameController.text,
                            password: _passwordController.text,
                          ),
                  child: state.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Войти как владелец'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.push('/platform-registration'),
                  child: const Text('Нет owner? Зарегистрировать платформу'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/cashier-login'),
                  child: const Text('Перейти ко входу кассира'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
