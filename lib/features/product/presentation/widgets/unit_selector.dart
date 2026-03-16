import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../measurement_unit/presentation/bloc/unit_bloc.dart';
import '../../../measurement_unit/presentation/bloc/unit_event.dart';
import '../../../measurement_unit/presentation/bloc/unit_state.dart';

/// Reusable widget for selecting a measurement unit with an "add" button.
/// Used in both AddProductPage and EditProductPage.
class UnitSelector extends StatelessWidget {
  final String selectedUnit;
  final ValueChanged<String> onChanged;

  const UnitSelector({
    super.key,
    required this.selectedUnit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: BlocBuilder<UnitBloc, UnitState>(
            builder: (context, state) {
              List<String> units = [l.unitDefault];
              if (state is UnitLoaded) {
                units = state.units.map((u) => u.shortName).toList();
                if (!units.contains(l.unitDefault)) {
                  units.insert(0, l.unitDefault);
                }
              }

              final effectiveUnit =
                  units.contains(selectedUnit) ? selectedUnit : units.first;

              return DropdownButtonFormField<String>(
                initialValue: effectiveUnit,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) onChanged(val);
                },
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () => _showAddUnitDialog(context),
            padding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  void _showAddUnitDialog(BuildContext context) {
    final nameController = TextEditingController();
    final shortNameController = TextEditingController();
    final l = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addUnit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l.unitNameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: shortNameController,
              decoration: InputDecoration(labelText: l.unitShortNameLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  shortNameController.text.isNotEmpty) {
                context.read<UnitBloc>().add(AddUnitEvent(
                      name: nameController.text,
                      shortName: shortNameController.text,
                    ));
                Navigator.pop(ctx);
              }
            },
            child: Text(l.add),
          ),
        ],
      ),
    );
  }
}
