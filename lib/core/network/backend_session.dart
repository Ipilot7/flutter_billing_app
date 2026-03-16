import 'package:billing_app/core/data/app_database.dart';

class BackendSession {
  static const roleOwner = 'owner';
  static const roleCashier = 'cashier';

  static const defaultApiBasePath = '/api/v1/';
  static const _accessTokenKey = 'backend.access_token';
  static const _refreshTokenKey = 'backend.refresh_token';
  static const _terminalIdKey = 'backend.terminal_id';
  static const _deviceIdKey = 'backend.device_id';
  static const _storeIdKey = 'backend.store_id';
  static const _organizationIdKey = 'backend.organization_id';
  static const _shiftIdKey = 'backend.shift_id';
  static const _roleKey = 'backend.role';

  final AppDatabase _db;
  String _baseUrl;

  BackendSession(this._db, {required String defaultBaseUrl})
      : _baseUrl = normalizeBaseUrl(defaultBaseUrl);

  Future<String?> getBaseUrl() async => _baseUrl;
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

  Future<String?> getDeviceId() => _db.getSetting(_deviceIdKey);

  Future<int?> getOrganizationId() async {
    final raw = await _db.getSetting(_organizationIdKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<int?> getCurrentShiftId() async {
    final raw = await _db.getSetting(_shiftIdKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<String?> getSessionRole() => _db.getSetting(_roleKey);

  Future<void> saveBaseUrl(String baseUrl) async {
    _baseUrl = normalizeBaseUrl(baseUrl);
  }

  Future<void> ensureBaseUrlInitialized({
    required String defaultBaseUrl,
  }) async {
    final normalizedCurrent = normalizeBaseUrl(_baseUrl);
    final normalizedDefault = normalizeBaseUrl(defaultBaseUrl);
    final normalizedLower = normalizedCurrent.toLowerCase();

    final isLegacyLocalhost = normalizedLower.startsWith('http://127.0.0.1') ||
        normalizedLower.startsWith('https://127.0.0.1') ||
        normalizedLower.startsWith('http://localhost') ||
        normalizedLower.startsWith('https://localhost');

    if (normalizedCurrent.isEmpty || isLegacyLocalhost) {
      _baseUrl = normalizedDefault;
    } else {
      _baseUrl = normalizedCurrent;
    }
  }

  static String normalizeBaseUrl(String baseUrl) {
    final input = baseUrl.trim();
    if (input.isEmpty) return input;

    final hasScheme =
        RegExp(r'^https?://', caseSensitive: false).hasMatch(input);
    final raw = hasScheme ? input : 'http://$input';
    final uri = Uri.parse(raw);

    final versionedApiPath = RegExp(r'^/api/v\d+/?$', caseSensitive: false);
    final apiRootPath = RegExp(r'^/api/?$', caseSensitive: false);

    var normalizedPath = uri.path;
    if (normalizedPath.isEmpty || normalizedPath == '/') {
      normalizedPath = defaultApiBasePath;
    } else if (apiRootPath.hasMatch(normalizedPath)) {
      normalizedPath = defaultApiBasePath;
    } else if (versionedApiPath.hasMatch(normalizedPath)) {
      if (!normalizedPath.endsWith('/')) {
        normalizedPath = '$normalizedPath/';
      }
    } else if (!normalizedPath.endsWith('/')) {
      normalizedPath = '$normalizedPath/';
    }

    return uri
        .replace(path: normalizedPath, query: null, fragment: null)
        .toString();
  }

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

  Future<void> saveOwnerContext({
    required int storeId,
    required int organizationId,
  }) async {
    await _db.saveSetting(_storeIdKey, storeId.toString());
    await _db.saveSetting(_organizationIdKey, organizationId.toString());
  }

  Future<void> saveDeviceId(String deviceId) =>
      _db.saveSetting(_deviceIdKey, deviceId.trim());

  Future<void> saveCurrentShiftId(int shiftId) =>
      _db.saveSetting(_shiftIdKey, shiftId.toString());

  Future<void> saveSessionRole(String role) => _db.saveSetting(_roleKey, role);

  Future<void> clearShift() => _db.deleteSetting(_shiftIdKey);

  Future<void> clearAuth() async {
    await _db.deleteSetting(_accessTokenKey);
    await _db.deleteSetting(_refreshTokenKey);
    await _db.deleteSetting(_terminalIdKey);
    await _db.deleteSetting(_storeIdKey);
    await _db.deleteSetting(_organizationIdKey);
    await _db.deleteSetting(_shiftIdKey);
    await _db.deleteSetting(_roleKey);
  }
}
