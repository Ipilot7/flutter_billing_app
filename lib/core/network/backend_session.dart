import 'package:billing_app/core/data/app_database.dart';

class BackendSession {
  static const _baseUrlKey = 'backend.base_url';
  static const _accessTokenKey = 'backend.access_token';
  static const _refreshTokenKey = 'backend.refresh_token';
  static const _terminalIdKey = 'backend.terminal_id';
  static const _storeIdKey = 'backend.store_id';
  static const _organizationIdKey = 'backend.organization_id';
  static const _shiftIdKey = 'backend.shift_id';

  final AppDatabase _db;

  BackendSession(this._db);

  Future<String?> getBaseUrl() => _db.getSetting(_baseUrlKey);
  Future<String?> getAccessToken() => _db.getSetting(_accessTokenKey);
  Future<String?> getRefreshToken() => _db.getSetting(_refreshTokenKey);

  Future<int?> getTerminalId() async {
    final raw = await _db.getSetting(_terminalIdKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<int?> getStoreId() async {
    final raw = await _db.getSetting(_storeIdKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<int?> getOrganizationId() async {
    final raw = await _db.getSetting(_organizationIdKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<int?> getCurrentShiftId() async {
    final raw = await _db.getSetting(_shiftIdKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> saveBaseUrl(String baseUrl) =>
      _db.saveSetting(_baseUrlKey, baseUrl.trim());

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _db.saveSetting(_accessTokenKey, access);
    await _db.saveSetting(_refreshTokenKey, refresh);
  }

  Future<void> saveTerminalContext({
    required int terminalId,
    required int storeId,
    required int organizationId,
  }) async {
    await _db.saveSetting(_terminalIdKey, terminalId.toString());
    await _db.saveSetting(_storeIdKey, storeId.toString());
    await _db.saveSetting(_organizationIdKey, organizationId.toString());
  }

  Future<void> saveCurrentShiftId(int shiftId) =>
      _db.saveSetting(_shiftIdKey, shiftId.toString());

  Future<void> clearShift() => _db.deleteSetting(_shiftIdKey);

  Future<void> clearAuth() async {
    await _db.deleteSetting(_accessTokenKey);
    await _db.deleteSetting(_refreshTokenKey);
    await _db.deleteSetting(_terminalIdKey);
    await _db.deleteSetting(_storeIdKey);
    await _db.deleteSetting(_organizationIdKey);
    await _db.deleteSetting(_shiftIdKey);
  }
}
