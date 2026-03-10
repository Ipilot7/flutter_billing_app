import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billing_app/features/measurement_unit/domain/entities/unit.dart';
import 'package:billing_app/features/measurement_unit/presentation/bloc/unit_bloc.dart';
import 'package:billing_app/features/measurement_unit/presentation/bloc/unit_event.dart';
import 'package:billing_app/features/measurement_unit/presentation/bloc/unit_state.dart';
import 'package:billing_app/l10n/app_localizations.dart';

class MeasurementUnitsPage extends StatelessWidget {
  const MeasurementUnitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.measurementUnits),
      ),
      body: BlocBuilder<UnitBloc, UnitState>(
        builder: (context, state) {
          if (state is UnitLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UnitError) {
            return Center(child: Text(state.message));
          }
          if (state is UnitLoaded) {
            if (state.units.isEmpty) {
              return Center(
                  child: Text(AppLocalizations.of(context)!.noUnitsFound));
            }
            return ListView.builder(
              itemCount: state.units.length,
              itemBuilder: (context, index) {
                final unit = state.units[index];
                return _UnitListTile(unit: unit);
              },
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUnitDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _UnitDialog(),
    );
  }
}

class _UnitListTile extends StatelessWidget {
  final Unit unit;

  const _UnitListTile({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(unit.name),
        subtitle: Text('(${unit.shortName})'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => _UnitDialog(unit: unit),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.deleteUnit),
                    content: Text(AppLocalizations.of(context)!
                        .deleteUnitConfirm(unit.name)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          context
                              .read<UnitBloc>()
                              .add(DeleteUnitEvent(id: unit.id));
                          Navigator.pop(ctx);
                        },
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitDialog extends StatefulWidget {
  final Unit? unit;

  const _UnitDialog({this.unit});

  @override
  State<_UnitDialog> createState() => _UnitDialogState();
}

class _UnitDialogState extends State<_UnitDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit?.name ?? '');
    _shortNameController =
        TextEditingController(text: widget.unit?.shortName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.unit == null
          ? AppLocalizations.of(context)!.addUnit
          : AppLocalizations.of(context)!.editUnit),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.unitName),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterName;
                }
                return null;
              },
            ),
            TextFormField(
              controller: _shortNameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.unitShortName),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.requiredLabel;
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
              if (widget.unit == null) {
                context.read<UnitBloc>().add(AddUnitEvent(
                      name: _nameController.text,
                      shortName: _shortNameController.text,
                    ));
              } else {
                context.read<UnitBloc>().add(UpdateUnitEvent(
                      id: widget.unit!.id,
                      name: _nameController.text,
                      shortName: _shortNameController.text,
                    ));
              }
              Navigator.pop(context);
            }
          },
          child: Text(widget.unit == null
              ? AppLocalizations.of(context)!.add
              : AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
