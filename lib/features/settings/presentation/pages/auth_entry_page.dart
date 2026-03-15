import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:billing_app/features/settings/presentation/bloc/auth_flow_cubits.dart';
import 'package:billing_app/core/service_locator.dart';

class AuthEntryPage extends StatefulWidget {
  const AuthEntryPage({super.key});

  @override
  State<AuthEntryPage> createState() => _AuthEntryPageState();
}

class _AuthEntryPageState extends State<AuthEntryPage> {
  late final AuthEntryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<AuthEntryCubit>()..checkSession();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<AuthEntryCubit, AuthEntryState>(
        listenWhen: (prev, curr) =>
            prev.redirectRoute != curr.redirectRoute &&
            curr.redirectRoute != null,
        listener: (context, state) {
          final route = state.redirectRoute;
          if (route != null) {
            context.go(route);
          }
        },
        child: BlocBuilder<AuthEntryCubit, AuthEntryState>(
          builder: (context, state) {
            if (state.checking) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('DeepPOS Вход'),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'Кассир'),
                      Tab(text: 'Владелец'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    _RoleEntryCard(
                      title: 'Рабочая касса',
                      subtitle: 'Вход по device_id и PIN для продаж.',
                      primaryLabel: 'Вход кассира',
                      onPrimaryTap: () => context.go('/cashier-login'),
                    ),
                    _RoleEntryCard(
                      title: 'Администрирование',
                      subtitle:
                          'Owner вход по username/password и управление кассами в Settings.',
                      primaryLabel: 'Вход владельца',
                      onPrimaryTap: () => context.go('/owner-login'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleEntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;

  const _RoleEntryCard({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onPrimaryTap,
                  child: Text(primaryLabel),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
