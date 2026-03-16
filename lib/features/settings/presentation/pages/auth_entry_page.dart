import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:billing_app/l10n/app_localizations.dart';

import 'package:billing_app/features/settings/presentation/bloc/auth_flow_cubits.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/features/settings/presentation/pages/cashier_login_page.dart';
import 'package:billing_app/features/settings/presentation/pages/owner_login_page.dart';

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
                  title: Text('${AppLocalizations.of(context)!.appTitle} ${AppLocalizations.of(context)!.loginTitle}'),
                  bottom: TabBar(
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.cashier),
                      Tab(text: AppLocalizations.of(context)!.owner),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    const CashierLoginPage.embedded(),
                    const OwnerLoginPage.embedded(),
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
