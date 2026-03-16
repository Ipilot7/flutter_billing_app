import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/backend_session.dart';
import '../../../../core/network/backend_v1_client.dart';
import '../../../../core/service_locator.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/billing_bloc.dart';

class CheckoutHelper {
  static Future<(String, String)?> resolveShiftForSale(
    BuildContext context,
    dynamic currentShift,
  ) async {
    if (currentShift != null) {
      return (currentShift.id as String, currentShift.openedBy as String);
    }

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final session = sl<BackendSession>();
    final baseUrl = await session.getBaseUrl();
    final token = await session.getAccessToken();
    final terminalId = await session.getTerminalId();
    final backendShiftId = await session.getCurrentShiftId();

    final isBackendMode = baseUrl != null &&
        baseUrl.isNotEmpty &&
        token != null &&
        token.isNotEmpty &&
        terminalId != null;

    if (isBackendMode && backendShiftId == null) {
      final restoredShiftId = await sl<BackendV1Client>().restoreOpenShiftIdForCurrentTerminal();
      if (restoredShiftId != null) {
        return (restoredShiftId.toString(), 'backend-cashier');
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Backend shift is not open. Open shift in Backend V1 Setup.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }

    if (isBackendMode && backendShiftId != null) {
      return (backendShiftId.toString(), 'backend-cashier');
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.pleaseOpenShift),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return null;
  }

  static void editGlobalDiscount(BuildContext context, String initialValue) {
    final controller = TextEditingController(text: initialValue);
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discount),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<BillingBloc>().add(UpdateGlobalDiscountEvent(
                    double.tryParse(controller.text) ?? 0.0));
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
