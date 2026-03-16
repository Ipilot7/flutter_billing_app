import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:billing_app/l10n/app_localizations.dart';

import 'package:billing_app/features/settings/presentation/bloc/auth_flow_cubits.dart';
import 'package:billing_app/core/service_locator.dart';

class OwnerLoginPage extends StatefulWidget {
  final bool embedded;

  const OwnerLoginPage({super.key}) : embedded = false;

  const OwnerLoginPage.embedded({super.key}) : embedded = true;

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
          final content = ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.username),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
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
                    : Text(AppLocalizations.of(context)!.ownerLogin),
              ),
              if (!widget.embedded) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/cashier-login'),
                  child: Text(AppLocalizations.of(context)!.cashierLogin),
                ),
              ],
            ],
          );

          if (widget.embedded) {
            return content;
          }

          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.ownerLogin)),
            body: content,
          );
        },
      ),
    );
  }
}
