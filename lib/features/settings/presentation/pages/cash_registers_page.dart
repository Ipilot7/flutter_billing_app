import 'package:flutter/material.dart';
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
    final terminals = await _client.fetchTerminals();
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
      text: terminal['name']?.toString() ?? 'Касса',
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Переименовать кассу'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Название кассы'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Сохранить'),
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
        const SnackBar(content: Text('Название кассы обновлено')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления кассы: $e')),
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
              Text(nextValue ? 'Касса активирована' : 'Касса деактивирована'),
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления статуса: $e')),
      );
    }
  }

  Future<void> _deleteTerminal(Map<String, dynamic> terminal) async {
    final terminalId = _parseTerminalId(terminal);
    if (terminalId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить кассу'),
        content: const Text('Вы уверены, что хотите удалить эту кассу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _client.deleteTerminal(terminalId: terminalId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Касса удалена')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления кассы: $e')),
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
          title: const Text('Кассы'),
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
                      'Не удалось загрузить список касс: ${snapshot.error}'),
                ),
              );
            }

            final terminals = snapshot.data ?? const <Map<String, dynamic>>[];
            if (terminals.isEmpty) {
              return const Center(
                child: Text('Пока нет добавленных касс'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: terminals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final terminal = terminals[index];
                final name = terminal['name']?.toString() ?? 'Касса';
                final active = terminal['is_active'] == true;

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  title: Text(name),
                  subtitle: Text(active ? 'Активна' : 'Неактивна'),
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
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Переименовать'),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(active ? 'Деактивировать' : 'Активировать'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Удалить'),
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
            await context.push('/settings/cash-register-setup');
            if (!mounted) return;
            _refresh();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
