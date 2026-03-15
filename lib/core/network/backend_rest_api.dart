import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'backend_rest_api.g.dart';

@RestApi()
abstract class BackendRestApi {
  factory BackendRestApi(Dio dio, {String? baseUrl}) = _BackendRestApi;

  @POST('auth/register/platform/')
  Future<dynamic> registerPlatform(
    @Body() Map<String, dynamic> body,
  );

  @POST('auth/register/cash-register/')
  Future<dynamic> registerCashRegister(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> body,
  );

  @POST('auth/login/cashier-terminal/')
  Future<dynamic> loginCashierTerminal(
    @Body() Map<String, dynamic> body,
  );

  @POST('token/')
  Future<dynamic> loginOwner(
    @Body() Map<String, dynamic> body,
  );

  @POST('token/refresh/')
  Future<dynamic> refreshToken(
    @Body() Map<String, dynamic> body,
  );

  @POST('shifts/')
  Future<dynamic> openShift(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> body,
  );

  @POST('sales/')
  Future<dynamic> createSale(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> body,
  );

  @GET('products/')
  Future<dynamic> fetchProducts(
    @Header('Authorization') String authorization,
  );

  @POST('products/')
  Future<dynamic> createProduct(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> body,
  );
}
