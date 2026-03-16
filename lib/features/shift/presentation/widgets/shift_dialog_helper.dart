import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';

class ShiftDialogHelper {
  static void showShiftDialog(BuildContext context, bool isOpen) {
    if (isOpen) {
      _showCloseShiftDialog(context);
    } else {
      _showOpenShiftDialog(context);
    }
  }

  static void _showCloseShiftDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final shiftBloc = context.read<ShiftBloc>();
    final currentShift = shiftBloc.currentShift;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.closeShift),
        content: Text(
          '${l.startBalance}: ${l.currency} ${currentShift?.startBalance.toStringAsFixed(2) ?? "0"}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final controller = TextEditingController();
              showDialog(
                context: ctx,
                builder: (context) => AlertDialog(
                  title: Text(l.endBalance),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.enterEndBalance,
                      prefixText: '${l.currency} ',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final balance = double.tryParse(controller.text) ?? 0;
                        ctx.read<ShiftBloc>().add(CloseShiftEvent(endBalance: balance));
                        Navigator.pop(context);
                        Navigator.pop(ctx);
                      },
                      child: Text(l.close),
                    ),
                  ],
                ),
              );
            },
            child: Text(l.closeShift),
          ),
        ],
      ),
    );
  }

  static void _showOpenShiftDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final startBalanceController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.openShift),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l.startBalance,
            prefixText: '${l.currency} ',
          ),
          controller: startBalanceController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final balance = double.tryParse(startBalanceController.text) ?? 0;
              context.read<ShiftBloc>().add(OpenShiftEvent(
                    startBalance: balance,
                    openedBy: l.cashier,
                  ));
              Navigator.pop(ctx);
            },
            child: Text(l.open),
          ),
        ],
      ),
    );
  }
}
