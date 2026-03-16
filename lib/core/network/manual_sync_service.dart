import 'package:billing_app/core/data/app_database.dart';
import 'package:uuid/uuid.dart';

import 'backend_session.dart';
import 'backend_v1_client.dart';
import 'sync/catalog_sync_processor.dart';
import 'sync/sale_sync_processor.dart';
import 'sync/sync_models.dart';

const _syncCursorKey = 'backend.sync_cursor';

class ManualSyncResult {
  final SyncProgress _progress;

  const ManualSyncResult(this._progress);

  int get preparedCategoryOperations => _progress.preparedCategories;
  int get preparedProductOperations => _progress.preparedProducts;
  int get preparedSaleOperations => _progress.preparedSales;
  int get skippedSales => _progress.skippedSales;
  int get appliedOperations => _progress.appliedOps;
  int get duplicateOperations => _progress.duplicateOps;
  int get failedOperations => _progress.failedOps;
  int get pulledCategories => _progress.pulledCategories;
  int get insertedCategories => _progress.insertedCategories;
  int get updatedCategories => _progress.updatedCategories;
  int get pulledProducts => _progress.pulledProducts;
  int get insertedProducts => _progress.insertedProducts;
  int get updatedProducts => _progress.updatedProducts;
  bool get terminalMissing => _progress.terminalMissing;
  bool get backendShiftMissing => _progress.backendShiftMissing;
  List<String> get failureReasons => _progress.failureReasons;

  String get summary {
    final lines = <String>[
      'sync/push: категорий $preparedCategoryOperations, товаров $preparedProductOperations, чеков $preparedSaleOperations',
      'push результат: applied $appliedOperations, duplicates $duplicateOperations, failed $failedOperations',
      'sync/pull: категорий $pulledCategories, добавлено $insertedCategories, обновлено $updatedCategories',
      'sync/pull: получено товаров $pulledProducts, добавлено $insertedProducts, обновлено $updatedProducts',
    ];

    if (skippedSales > 0) {
      lines.add('Чеки пропущены: $skippedSales');
    }
    if (terminalMissing) {
      lines.add('Push пропущен: касса не имеет terminal_id');
    }
    if (backendShiftMissing) {
      lines.add('Чеки не отправлены: на сервере нет открытой смены');
    }

    if (failureReasons.isNotEmpty) {
      lines.add('Ошибки при отправке:');
      for (final reason in failureReasons.take(5)) {
        lines.add('  - $reason');
      }
      if (failureReasons.length > 5) {
        lines.add('  ... и еще ${failureReasons.length - 5} ошибок');
      }
    }

    return lines.join('\n');
  }
}

class ManualSyncService {
  static const _uuid = Uuid();

  final AppDatabase _db;
  final BackendSession _session;
  final BackendV1Client _client;
  
  late final CatalogSyncProcessor _catalogProcessor;
  late final SaleSyncProcessor _saleProcessor;

  ManualSyncService(this._db, this._session, this._client) {
    _catalogProcessor = CatalogSyncProcessor(_db);
    _saleProcessor = SaleSyncProcessor(_db);
  }

  Future<ManualSyncResult> syncProducts() async {
    final token = await _session.getAccessToken();
    final baseUrl = await _session.getBaseUrl();

    if (baseUrl == null || baseUrl.trim().isEmpty) {
      throw BackendApiException('Backend URL is not configured.');
    }
    if (token == null || token.trim().isEmpty) {
      throw BackendApiException('Login is required to sync data.');
    }

    final progress = SyncProgress();
    final organizationId = await _session.getOrganizationId();
    var terminalId = await _session.getTerminalId();
    terminalId ??= await _resolveTerminalIdForSync();

    final operations = <Map<String, dynamic>>[];
    final saleOperationIds = <String, String>{};

    // 1. Prepare Catalog Ops
    await _catalogProcessor.prepareOperations(
      operations: operations,
      progress: progress,
      buildOperationId: _buildOperationId,
    );

    // 2. Resolve Backend Shift
    final backendShiftId = terminalId == null ? null : await _resolveBackendShiftId();

    // 3. Prepare Sale Ops
    await _saleProcessor.prepareOperations(
      operations: operations,
      progress: progress,
      saleOperationIds: saleOperationIds,
      backendShiftId: backendShiftId,
      buildOperationId: _buildOperationId,
    );

    if (terminalId == null) {
      progress.terminalMissing = true;
    } else {
      if (backendShiftId == null && progress.skippedSales > 0) {
        progress.backendShiftMissing = true;
      }

      // 4. Push Operations
      if (operations.isNotEmpty) {
        try {
          final response = await _client.pushSyncOperations(
            terminalId: terminalId,
            operations: operations,
          );
          await _saleProcessor.handlePushResults(
            response: response,
            progress: progress,
            saleOperationIds: saleOperationIds,
          );
        } catch (e) {
          progress.addFailure('Push failed: $e');
        }
      }
    }

    // 5. Pull Data
    try {
      final lastCursor = await _db.getSetting(_syncCursorKey);
      final syncPull = await _client.pullSyncData(
        since: lastCursor,
        organizationId: organizationId,
      );

      final nextCursor = syncPull['next_cursor']?.toString();
      if (nextCursor != null && nextCursor.isNotEmpty) {
        await _db.saveSetting(_syncCursorKey, nextCursor);
      }

      final data = syncPull['data'];
      if (data is Map<String, dynamic>) {
        await _catalogProcessor.pullDataFromSyncPayload(data, progress);
      }
    } catch (e) {
      progress.addFailure('Pull failed: $e');
    }

    return ManualSyncResult(progress);
  }

  Future<int?> _resolveBackendShiftId() async {
    final restoredShiftId = await _client.restoreOpenShiftIdForCurrentTerminal();
    if (restoredShiftId != null) {
      return restoredShiftId;
    }

    try {
      final localShiftQuery = _db.select(_db.shifts)..where((t) => t.status.equals(0));
      final localShifts = await localShiftQuery.get();
      final localShift = localShifts.firstOrNull;

      if (localShift != null) {
        final response = await _client.openShift(
          startBalance: localShift.startBalance.toDouble(),
        );
        final backendShiftId = response['id'];
        if (backendShiftId != null) {
          return backendShiftId as int?;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<int?> _resolveTerminalIdForSync() async {
    final role = await _session.getSessionRole();
    if (role != BackendSession.roleOwner) return null;

    List<Map<String, dynamic>> terminals;
    try {
      terminals = await _client.fetchTerminalsFromSyncPull();
    } catch (_) {
      try {
        terminals = await _client.fetchTerminals();
      } catch (_) {
        return null;
      }
    }

    if (terminals.isEmpty) return null;

    final preferredStoreId = await _session.getStoreId();
    final organizationId = await _session.getOrganizationId();

    Map<String, dynamic>? pick;
    if (preferredStoreId != null) {
      for (final terminal in terminals) {
        final storeId = _toInt(terminal['store']);
        final isActive = terminal['is_active'] != false;
        if (storeId == preferredStoreId && isActive) {
          pick = terminal;
          break;
        }
      }
    }

    pick ??= terminals.cast<Map<String, dynamic>?>().firstWhere(
          (terminal) => terminal?['is_active'] != false,
          orElse: () => null,
        );

    if (pick == null) return null;

    final terminalId = _toInt(pick['id']);
    if (terminalId == null) return null;

    final storeId = _toInt(pick['store']);
    if (storeId != null && organizationId != null) {
      await _session.saveTerminalContext(
        terminalId: terminalId,
        storeId: storeId,
        organizationId: organizationId,
      );
    }

    return terminalId;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  String _buildOperationId({
    required String entityType,
    required String entityId,
    required int? signature,
  }) {
    final seed = signature == null
        ? '$entityType:$entityId'
        : '$entityType:$entityId:$signature';
    return _uuid.v5(Namespace.url.value, seed);
  }
}
