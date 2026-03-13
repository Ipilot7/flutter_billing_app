import 'dart:convert';

import 'package:http/http.dart' as http;

import 'backend_session.dart';

class BackendApiException implements Exception {
  final String message;
  final int? statusCode;

  BackendApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class BackendV1Client {
  final BackendSession _session;
  final http.Client _httpClient;

  BackendV1Client(this._session, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

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
      await _session.saveTokens(
        access: tokens['access'] as String,
        refresh: tokens['refresh'] as String,
      );
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
      await _session.saveTokens(
        access: tokens['access'] as String,
        refresh: tokens['refresh'] as String,
      );
    }

    if (terminal != null && store != null) {
      await _session.saveTerminalContext(
        terminalId: terminal['id'] as int,
        storeId: store['id'] as int,
        organizationId: store['organization_id'] as int,
      );
    }

    return response;
  }

  Future<Map<String, dynamic>> openShift({required double startBalance}) async {
    final terminalId = await _session.getTerminalId();
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
      await _session.saveCurrentShiftId(shiftId);
    }

    return response;
  }

  Future<Map<String, dynamic>> createSale({
    required String receiptNumber,
    required String paymentType,
    required List<Map<String, dynamic>> items,
  }) async {
    final shiftId = await _session.getCurrentShiftId();
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

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    required bool withAuth,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(withAuth: withAuth);

    final response = await _httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  Future<dynamic> _get(
    String path, {
    required bool withAuth,
  }) async {
    final uri = await _buildUri(path);
    final headers = await _buildHeaders(withAuth: withAuth);

    final response = await _httpClient.get(uri, headers: headers);

    return _decodeResponseAny(response);
  }

  Future<Uri> _buildUri(String path) async {
    final baseUrl = await _session.getBaseUrl();
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
      final token = await _session.getAccessToken();
      if (token == null || token.isEmpty) {
        throw BackendApiException('Not authenticated. Perform login first.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded =
        response.body.isEmpty ? {} : jsonDecode(response.body);
    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'detail': decoded.toString()};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw BackendApiException(
      _mapErrorMessage(_extractErrorMessage(body), response.statusCode),
      statusCode: response.statusCode,
    );
  }

  dynamic _decodeResponseAny(http.Response response) {
    final dynamic decoded =
        response.body.isEmpty ? {} : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'detail': decoded.toString()};

    throw BackendApiException(
      _mapErrorMessage(_extractErrorMessage(body), response.statusCode),
      statusCode: response.statusCode,
    );
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
}
