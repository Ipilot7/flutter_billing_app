class CashierQrPayload {
  static const _scheme = 'deeppos';
  static const _host = 'cashier-device';
  static const _version = '1';

  static String build({required String deviceId}) {
    final uri = Uri(
      scheme: _scheme,
      host: _host,
      queryParameters: {
        'v': _version,
        'device_id': deviceId,
      },
    );
    return uri.toString();
  }

  static String? parseDeviceId(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    if (uri.scheme != _scheme || uri.host != _host) return null;
    if (uri.queryParameters['v'] != _version) return null;

    final deviceId = uri.queryParameters['device_id']?.trim();
    if (deviceId == null || deviceId.isEmpty) return null;
    return deviceId;
  }
}
