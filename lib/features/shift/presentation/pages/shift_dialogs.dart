import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billing_app/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:billing_app/features/shift/presentation/bloc/shift_event.dart';
import 'package:billing_app/l10n/app_localizations.dart';

class OpenShiftDialog extends StatefulWidget {
  const OpenShiftDialog({super.key});

  @override
  State<OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends State<OpenShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  final _balanceController = TextEditingController(text: '0');

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.openShift),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _balanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.startBalance,
            prefixText: '${AppLocalizations.of(context)!.currency} ',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.enterStartBalance;
            }
            if (double.tryParse(value) == null) {
              return AppLocalizations.of(context)!.invalidNumber;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<ShiftBloc>().add(OpenShiftEvent(
                    startBalance: double.tryParse(_balanceController.text) ?? 0.0,
                    openedBy: AppLocalizations.of(context)!.cashier,
                  ));
            }
          },
          child: Text(AppLocalizations.of(context)!.open),
        ),
      ],
    );
  }
}

class CloseShiftDialog extends StatefulWidget {
  final double startBalance;

  const CloseShiftDialog({super.key, required this.startBalance});

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.closeShift),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${AppLocalizations.of(context)!.startBalance}: ${AppLocalizations.of(context)!.currency} ${widget.startBalance.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.endBalance,
                prefixText: '${AppLocalizations.of(context)!.currency} ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterEndBalance;
                }
                if (double.tryParse(value) == null) {
                  return AppLocalizations.of(context)!.invalidNumber;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<ShiftBloc>().add(CloseShiftEvent(
                    endBalance: double.tryParse(_balanceController.text) ?? 0.0,
                  ));
            }
          },
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }
}
