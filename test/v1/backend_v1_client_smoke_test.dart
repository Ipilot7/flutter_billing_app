import 'package:billing_app/core/network/backend_v1_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendV1Client mock smoke', () {
    test('full flow login -> open shift -> create sale -> fetch products',
        () async {
      String? baseUrl = 'http://localhost:8000/api/v1/';
      String? accessToken;
      String? refreshToken;
      int? terminalId;
      int? storeId;
      int? organizationId;
      int? shiftId;

      final mockDio = Dio();
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final requestPath = options.uri.path;

            if (requestPath.endsWith('/auth/login/cashier-terminal/') &&
                options.method == 'POST') {
              final body = options.data as Map<String, dynamic>;
              expect(body['device_id'], 'dev-1');
              expect(body['cashier_pin'], '1234');

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'tokens': {
                      'access': 'token-access',
                      'refresh': 'token-refresh'
                    },
                    'terminal': {
                      'id': 10,
                      'name': 'Cash 1',
                      'device_id': 'dev-1',
                      'store_id': 3
                    },
                    'store': {
                      'id': 3,
                      'name': 'Main Store',
                      'organization_id': 1
                    },
                  },
                ),
              );
            }

            if (requestPath.endsWith('/shifts/') && options.method == 'POST') {
              expect(options.headers['Authorization'], 'Bearer token-access');
              final body = options.data as Map<String, dynamic>;
              expect(body['terminal'], 10);

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: {'id': 99, 'status': 'open'},
                ),
              );
            }

            if (requestPath.endsWith('/sales/') && options.method == 'POST') {
              expect(options.headers['Authorization'], 'Bearer token-access');
              final body = options.data as Map<String, dynamic>;
              expect(body['shift'], 99);
              expect(body['receipt_number'], 'R-1001');
              expect(body['items'], isA<List<dynamic>>());

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: {'id': 501, 'total': '100.00'},
                ),
              );
            }

            if (requestPath.endsWith('/products/') && options.method == 'GET') {
              expect(options.headers['Authorization'], 'Bearer token-access');

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': 101,
                      'name': 'Milk',
                      'barcode': '111',
                      'price': '50.00',
                      'cost': '30.00',
                      'stock': '12.000'
                    },
                    {
                      'id': 102,
                      'name': 'Bread',
                      'barcode': '222',
                      'price': '30.00',
                      'cost': '20.00',
                      'stock': '8.000'
                    },
                  ],
                ),
              );
            }

            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 404,
                data: {'detail': 'Not Found'},
              ),
            );
          },
        ),
      );

      final client = BackendV1Client.forTesting(
        dio: mockDio,
        baseUrlProvider: () async => baseUrl,
        accessTokenProvider: () async => accessToken,
        terminalIdProvider: () async => terminalId,
        shiftIdProvider: () async => shiftId,
        saveTokens: (access, refresh) async {
          accessToken = access;
          refreshToken = refresh;
        },
        saveTerminalContext: (t, s, o) async {
          terminalId = t;
          storeId = s;
          organizationId = o;
        },
        saveShiftId: (s) async {
          shiftId = s;
        },
      );

      final loginResponse = await client.loginCashierTerminal(
        deviceId: 'dev-1',
        cashierPin: '1234',
      );
      expect(loginResponse['tokens'], isNotNull);
      expect(accessToken, 'token-access');
      expect(refreshToken, 'token-refresh');
      expect(terminalId, 10);
      expect(storeId, 3);
      expect(organizationId, 1);

      final shiftResponse = await client.openShift(startBalance: 100.0);
      expect(shiftResponse['id'], 99);
      expect(shiftId, 99);

      final saleResponse = await client.createSale(
        receiptNumber: 'R-1001',
        paymentType: 'cash',
        items: [
          {
            'product_id': 101,
            'quantity': '2.000',
            'price': '50.00',
            'discount': '0.00',
          }
        ],
      );
      expect(saleResponse['id'], 501);

      final products = await client.fetchProducts();
      expect(products.length, 2);
      expect(products.first['name'], 'Milk');

      expect(baseUrl, isNotNull);
    });
  });
}
