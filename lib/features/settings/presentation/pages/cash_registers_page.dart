import 'package:flutter/material.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:billing_app/core/network/backend_v1_client.dart';
import 'package:billing_app/core/network/backend_session.dart';
import 'package:billing_app/core/service_locator.dart';

class CashRegistersPage extends StatefulWidget {
  const CashRegistersPage({super.key});

  @override
  State<CashRegistersPage> createState() => _CashRegistersPageState();
}

class _CashRegistersPageState extends State<CashRegistersPage> {
  final BackendV1Client _client = sl<BackendV1Client>();
  final BackendSession _session = sl<BackendSession>();
  final ValueNotifier<int> _uiTick = ValueNotifier<int>(0);

  late Future<List<Map<String, dynamic>>> _terminalsFuture;

  @override
  void initState() {
    super.initState();
    _terminalsFuture = _loadTerminals();
  }

  Future<List<Map<String, dynamic>>> _loadTerminals() async {
    List<Map<String, dynamic>> terminals;
    try {
      terminals = await _client.fetchTerminalsFromSyncPull();
    } catch (_) {
      terminals = await _client.fetchTerminals();
    }
    final storeId = await _session.getStoreId();

    if (storeId == null) {
      return terminals;
    }

    return terminals.where((terminal) {
      final dynamic rawStore = terminal['store'];
      final store = rawStore is int
          ? rawStore
          : rawStore is String
              ? int.tryParse(rawStore)
              : rawStore is double
                  ? rawStore.toInt()
                  : null;
      return store == storeId;
    }).toList();
  }

  void _refresh() {
    _terminalsFuture = _loadTerminals();
    _uiTick.value++;
  }

  int? _parseTerminalId(Map<String, dynamic> terminal) {
    final raw = terminal['id'];
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    if (raw is double) return raw.toInt();
    return null;
  }

  Future<void> _renameTerminal(Map<String, dynamic> terminal) async {
    final terminalId = _parseTerminalId(terminal);
    if (terminalId == null) return;

    final controller = TextEditingController(
      text: terminal['name']?.toString() ?? AppLocalizations.of(context)!.cashier,
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.renameTerminal),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.terminalName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (newName == null || newName.isEmpty) return;

    try {
      await _client.updateTerminal(terminalId: terminalId, name: newName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.terminalNameUpdated)),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.errorOccurred}: $e')),
      );
    }
  }

  Future<void> _toggleTerminalActive(Map<String, dynamic> terminal) async {
    final terminalId = _parseTerminalId(terminal);
    if (terminalId == null) return;

    final isActive = terminal['is_active'] == true;
    final nextValue = !isActive;

    try {
      await _client.updateTerminal(
        terminalId: terminalId,
        isActive: nextValue,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(nextValue ? AppLocalizations.of(context)!.terminalActivated : AppLocalizations.of(context)!.terminalDeactivated),
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.errorOccurred}: $e')),
      );
    }
  }

  Future<void> _deleteTerminal(Map<String, dynamic> terminal) async {
    final terminalId = _parseTerminalId(terminal);
    if (terminalId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTerminalTitle),
        content: Text(AppLocalizations.of(context)!.deleteTerminalConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _client.deleteTerminal(terminalId: terminalId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.terminalDeleted)),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.errorOccurred}: $e')),
      );
    }
  }

  @override
  void dispose() {
    _uiTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _uiTick,
      builder: (_, __, ___) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.terminals),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _terminalsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                      '${AppLocalizations.of(context)!.errorLoadingTerminals}: ${snapshot.error}'),
                ),
              );
            }

            final terminals = snapshot.data ?? const <Map<String, dynamic>>[];
            if (terminals.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.noTerminalsFound),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: terminals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final terminal = terminals[index];
                final name = terminal['name']?.toString() ?? AppLocalizations.of(context)!.cashier;
                final active = terminal['is_active'] == true;

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  title: Text(name),
                  subtitle: Text(active ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.inactive),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'rename') {
                        _renameTerminal(terminal);
                      } else if (action == 'toggle') {
                        _toggleTerminalActive(terminal);
                      } else if (action == 'delete') {
                        _deleteTerminal(terminal);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text(AppLocalizations.of(context)!.rename),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(active ? AppLocalizations.of(context)!.deactivate : AppLocalizations.of(context)!.activate),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final created =
                await context.push<bool>('/settings/cash-register-setup');
            if (!mounted) return;
            if (created == true) {
              _refresh();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
