import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'backend_session.dart';

class BackendApiException implements Exception {
  final String message;
  final int? statusCode;

  BackendApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class BackendV1Client {
  final BackendSession? _session;
  final Dio _dio;
  final Future<String?> Function()? _baseUrlProvider;
  final Future<String?> Function()? _accessTokenProvider;
  final Future<int?> Function()? _terminalIdProvider;
  final Future<int?> Function()? _shiftIdProvider;
  final Future<void> Function(String access, String refresh)? _saveTokens;
  final Future<void> Function(int terminalId, int storeId, int organizationId)?
      _saveTerminalContext;
  final Future<void> Function(int shiftId)? _saveShiftId;

  BackendV1Client(this._session, {Dio? dio})
      : _dio = dio ?? Dio(),
        _baseUrlProvider = null,
        _accessTokenProvider = null,
        _terminalIdProvider = null,
        _shiftIdProvider = null,
        _saveTokens = null,
        _saveTerminalContext = null,
        _saveShiftId = null {
    _setupDioLogging();
  }

  BackendV1Client.forTesting({
    required Future<String?> Function() baseUrlProvider,
    required Future<String?> Function() accessTokenProvider,
    required Future<int?> Function() terminalIdProvider,
    required Future<int?> Function() shiftIdProvider,
    required Future<void> Function(String access, String refresh) saveTokens,
    required Future<void> Function(
            int terminalId, int storeId, int organizationId)
        saveTerminalContext,
    required Future<void> Function(int shiftId) saveShiftId,
    Dio? dio,
  })  : _session = null,
        _dio = dio ?? Dio(),
        _baseUrlProvider = baseUrlProvider,
        _accessTokenProvider = accessTokenProvider,
        _terminalIdProvider = terminalIdProvider,
        _shiftIdProvider = shiftIdProvider,
        _saveTokens = saveTokens,
        _saveTerminalContext = saveTerminalContext,
        _saveShiftId = saveShiftId {
    _setupDioLogging();
  }

  void _setupDioLogging() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            final headers = Map<String, dynamic>.from(options.headers);
            if (headers.containsKey('Authorization')) {
              headers['Authorization'] = 'Bearer ***';
            }
            debugPrint('[DIO][REQ] ${options.method} ${options.uri}');
            debugPrint('[DIO][REQ][HEADERS] $headers');
            debugPrint('[DIO][REQ][BODY] ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
                '[DIO][RES] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
            debugPrint('[DIO][RES][BODY] ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint(
                '[DIO][ERR] ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.uri}');
            debugPrint('[DIO][ERR][BODY] ${error.response?.data}');
            debugPrint('[DIO][ERR][MESSAGE] ${error.message}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> registerPlatform({
    required String organizationName,
    required String storeName,
    required String ownerUsername,
    required String ownerPassword,
  }) async {
    final response = await _post(
      '/api/auth/register/platform/',
      body: {
        'organization_name': organizationName,
        'store_name': storeName,
        'owner_username': ownerUsername,
        'owner_password': ownerPassword,
      },
      withAuth: false,
    );

    final tokens = response['tokens'] as Map<String, dynamic>?;
    if (tokens != null) {
      await _persistTokens(
          tokens['access'] as String, tokens['refresh'] as String);
    }

    return response;
  }

  Future<Map<String, dynamic>> registerCashRegister({
    required int storeId,
    required String terminalName,
    required String deviceId,
    required String cashierUsername,
    required String cashierPassword,
    required String cashierPin,
  }) async {
    return _post(
      '/api/auth/register/cash-register/',
      body: {
        'store_id': storeId,
        'terminal_name': terminalName,
        'device_id': deviceId,
        'cashier_username': cashierUsername,
        'cashier_password': cashierPassword,
        'cashier_pin': cashierPin,
      },
      withAuth: true,
    );
  }

  Future<Map<String, dynamic>> loginCashierTerminal({
    required String deviceId,
    required String cashierPin,
  }) async {
    final response = await _post(
      '/api/auth/login/cashier-terminal/',
      body: {
        'device_id': deviceId,
        'cashier_pin': cashierPin,
      },
      withAuth: false,
    );

    final tokens = response['tokens'] as Map<String, dynamic>?;
    final terminal = response['terminal'] as Map<String, dynamic>?;
    final store = response['store'] as Map<String, dynamic>?;

    if (tokens != null) {
      await _persistTokens(
          tokens['access'] as String, tokens['refresh'] as String);
    }

    if (terminal != null && store != null) {
      await _persistTerminalContext(
        terminal['id'] as int,
        store['id'] as int,
        store['organization_id'] as int,
      );
    }

    return response;
  }

  Future<Map<String, dynamic>> loginOwner({
    required String username,
    required String password,
  }) async {
    final response = await _post(
      '/api/token/',
      body: {
        'username': username,
        'password': password,
      },
      withAuth: false,
    );

    final access = response['access']?.toString();
    final refresh = response['refresh']?.toString();
    if (access == null || refresh == null) {
      throw BackendApiException('Invalid owner login response.');
    }

    await _persistTokens(access, refresh);
    return response;
  }

  Future<Map<String, dynamic>> openShift({required double startBalance}) async {
    final terminalId = await _readTerminalId();
    if (terminalId == null) {
      throw BackendApiException(
          'Terminal is not configured. Login cashier first.');
    }

    final response = await _post(
      '/api/shifts/',
      body: {
        'terminal': terminalId,
        'start_balance': startBalance.toStringAsFixed(2),
        'status': 'open',
      },
      withAuth: true,
    );

    final shiftId = response['id'] as int?;
    if (shiftId != null) {
      await _persistShiftId(shiftId);
    }

    return response;
  }

  Future<Map<String, dynamic>> createSale({
    required String receiptNumber,
    required String paymentType,
    required List<Map<String, dynamic>> items,
  }) async {
    final shiftId = await _readShiftId();
    if (shiftId == null) {
      throw BackendApiException('No open shift in session. Open shift first.');
    }

    return _post(
      '/api/sales/',
      body: {
        'shift': shiftId,
        'receipt_number': receiptNumber,
        'payment_type': paymentType,
        'items': items,
      },
      withAuth: true,
    );
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await _get(
      '/api/products/',
      withAuth: true,
    );

    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }

    throw BackendApiException('Unexpected products response format.');
  }

  Future<Map<String, dynamic>> createProduct({
    required int organizationId,
    required String name,
    required String barcode,
    required double price,
    double cost = 0,
    double stock = 0,
    String sku = '',
    int? categoryId,
    double minStock = 0,
    bool isActive = true,
  }) async {
    return _post(
      '/api/products/',
      body: {
        'organization': organizationId,
        'category': categoryId,
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'price': price.toStringAsFixed(2),
        'cost': cost.toStringAsFixed(2),
        'stock': stock.toStringAsFixed(3),
        'min_stock': minStock.toStringAsFixed(3),
        'is_active': isActive,
      },
      withAuth: true,
    );
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    required bool withAuth,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(withAuth: withAuth);

    final response = await _dio.postUri(
      uri,
      data: body,
      options: Options(
        headers: headers,
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 600,
      ),
    );

    return _decodeResponse(response);
  }

  Future<dynamic> _get(
    String path, {
    required bool withAuth,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(withAuth: withAuth);

    final response = await _dio.getUri(
      uri,
      options: Options(
        headers: headers,
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 600,
      ),
    );

    return _decodeResponseAny(response);
  }

  Future<Uri> _buildUri(String path) async {
    final baseUrl = await _readBaseUrl();
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      throw BackendApiException('Backend URL is not configured.');
    }

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalizedBase$path');
  }

  Future<Map<String, String>> _buildHeaders({required bool withAuth}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _readAccessToken();
      if (token == null || token.isEmpty) {
        throw BackendApiException('Not authenticated. Perform login first.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _decodeResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final dynamic decoded = _normalizeResponseData(response.data);
    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'detail': decoded.toString()};

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    throw BackendApiException(
      _mapErrorMessage(_extractErrorMessage(body), statusCode),
      statusCode: statusCode,
    );
  }

  dynamic _decodeResponseAny(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final dynamic decoded = _normalizeResponseData(response.data);

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'detail': decoded.toString()};

    throw BackendApiException(
      _mapErrorMessage(_extractErrorMessage(body), statusCode),
      statusCode: statusCode,
    );
  }

  dynamic _normalizeResponseData(dynamic data) {
    if (data == null) return {};
    if (data is String) {
      if (data.isEmpty) return {};
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  String _extractErrorMessage(Map<String, dynamic> body) {
    if (body['detail'] != null) {
      return body['detail'].toString();
    }
    if (body['non_field_errors'] is List &&
        (body['non_field_errors'] as List).isNotEmpty) {
      return (body['non_field_errors'] as List).first.toString();
    }
    return body.toString();
  }

  String _mapErrorMessage(String raw, int statusCode) {
    if (statusCode == 429) {
      return 'Too many failed attempts. Please wait and try again.';
    }
    if (raw.contains('Insufficient stock')) {
      return 'Not enough stock for one of the items.';
    }
    if (raw.contains('closed shift')) {
      return 'Shift is closed. Open a shift first.';
    }
    if (raw.contains('Not authenticated')) {
      return 'Session expired. Login again.';
    }
    return raw;
  }

  Future<String?> _readBaseUrl() async {
    if (_baseUrlProvider != null) return _baseUrlProvider!();
    if (_session == null) return null;
    return _session!.getBaseUrl();
  }

  Future<String?> _readAccessToken() async {
    if (_accessTokenProvider != null) return _accessTokenProvider!();
    if (_session == null) return null;
    return _session!.getAccessToken();
  }

  Future<int?> _readTerminalId() async {
    if (_terminalIdProvider != null) return _terminalIdProvider!();
    if (_session == null) return null;
    return _session!.getTerminalId();
  }

  Future<int?> _readShiftId() async {
    if (_shiftIdProvider != null) return _shiftIdProvider!();
    if (_session == null) return null;
    return _session!.getCurrentShiftId();
  }

  Future<void> _persistTokens(String access, String refresh) async {
    if (_saveTokens != null) {
      await _saveTokens!(access, refresh);
      return;
    }
    if (_session != null) {
      await _session!.saveTokens(access: access, refresh: refresh);
    }
  }

  Future<void> _persistTerminalContext(
      int terminalId, int storeId, int organizationId) async {
    if (_saveTerminalContext != null) {
      await _saveTerminalContext!(terminalId, storeId, organizationId);
      return;
    }
    if (_session != null) {
      await _session!.saveTerminalContext(
        terminalId: terminalId,
        storeId: storeId,
        organizationId: organizationId,
      );
    }
  }

  Future<void> _persistShiftId(int shiftId) async {
    if (_saveShiftId != null) {
      await _saveShiftId!(shiftId);
      return;
    }
    if (_session != null) {
      await _session!.saveCurrentShiftId(shiftId);
    }
  }
}
