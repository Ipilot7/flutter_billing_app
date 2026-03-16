import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:billing_app/core/data/app_database.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/core/network/backend_session.dart';
import 'package:billing_app/core/network/backend_v1_client.dart';
import 'package:billing_app/core/network/cashier_qr_payload.dart';
import 'package:billing_app/features/shift/domain/usecases/shift_usecases.dart';

class AuthEntryState extends Equatable {
  final bool checking;
  final String? redirectRoute;

  const AuthEntryState({this.checking = true, this.redirectRoute});

  AuthEntryState copyWith({bool? checking, String? redirectRoute}) {
    return AuthEntryState(
      checking: checking ?? this.checking,
      redirectRoute: redirectRoute,
    );
  }

  @override
  List<Object?> get props => [checking, redirectRoute];
}

class AuthEntryCubit extends Cubit<AuthEntryState> {
  final BackendSession _session;

  AuthEntryCubit(this._session) : super(const AuthEntryState());

  Future<void> checkSession() async {
    final token = await _session.getAccessToken();
    final role = await _session.getSessionRole();
    final terminalId = await _session.getTerminalId();

    if (token != null && token.isNotEmpty) {
      if (role == BackendSession.roleCashier) {
        emit(const AuthEntryState(checking: false, redirectRoute: '/'));
        return;
      }

      if (role == BackendSession.roleOwner) {
        emit(const AuthEntryState(checking: false, redirectRoute: '/settings'));
        return;
      }

      if (terminalId != null) {
        emit(const AuthEntryState(checking: false, redirectRoute: '/'));
      } else {
        emit(const AuthEntryState(checking: false, redirectRoute: '/settings'));
      }
      return;
    }

    emit(const AuthEntryState(checking: false));
  }
}

class OwnerLoginState extends Equatable {
  final bool loading;
  final String? message;
  final String? error;
  final String? navigateTo;

  const OwnerLoginState({
    this.loading = false,
    this.message,
    this.error,
    this.navigateTo,
  });

  OwnerLoginState copyWith({
    bool? loading,
    String? message,
    String? error,
    String? navigateTo,
  }) {
    return OwnerLoginState(
      loading: loading ?? this.loading,
      message: message,
      error: error,
      navigateTo: navigateTo,
    );
  }

  @override
  List<Object?> get props => [loading, message, error, navigateTo];
}

class OwnerLoginCubit extends Cubit<OwnerLoginState> {
  final BackendV1Client _client;

  OwnerLoginCubit(this._client) : super(const OwnerLoginState());

  Future<void> login(
      {required String username, required String password}) async {
    if (username.trim().isEmpty || password.isEmpty) {
      emit(state.copyWith(error: 'Введите username и password.'));
      return;
    }

    emit(state.copyWith(
        loading: true, message: null, error: null, navigateTo: null));
    try {
      await _client.loginOwner(username: username.trim(), password: password);
      emit(state.copyWith(
        loading: false,
        message: 'Owner login успешен.',
        navigateTo: '/settings',
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Ошибка owner login: $e'));
    }
  }
}

class CashierLoginState extends Equatable {
  final bool loading;
  final bool isFirstRun;
  final String deviceId;
  final String? message;
  final String? error;
  final String? navigateTo;

  const CashierLoginState({
    this.loading = false,
    this.isFirstRun = false,
    this.deviceId = '',
    this.message,
    this.error,
    this.navigateTo,
  });

  CashierLoginState copyWith({
    bool? loading,
    bool? isFirstRun,
    String? deviceId,
    String? message,
    String? error,
    String? navigateTo,
  }) {
    return CashierLoginState(
      loading: loading ?? this.loading,
      isFirstRun: isFirstRun ?? this.isFirstRun,
      deviceId: deviceId ?? this.deviceId,
      message: message,
      error: error,
      navigateTo: navigateTo,
    );
  }

  @override
  List<Object?> get props =>
      [loading, isFirstRun, deviceId, message, error, navigateTo];
}

class CashierLoginCubit extends Cubit<CashierLoginState> {
  final BackendV1Client _client;
  final BackendSession _session;
  final AppDatabase _db;
  static const _uuid = Uuid();
  static final _deviceInfo = DeviceInfoPlugin();

  CashierLoginCubit(this._client, this._session, this._db)
      : super(const CashierLoginState());

  Future<void> loadStartupState() async {
    final terminalId = await _session.getTerminalId();
    var deviceId = (await _session.getDeviceId())?.trim() ?? '';
    if (deviceId.isEmpty) {
      deviceId = await _resolveDeviceId();
      await _session.saveDeviceId(deviceId);
    }

    emit(state.copyWith(
      isFirstRun: terminalId == null,
      deviceId: deviceId,
    ));
  }

  Future<void> refreshDeviceId() => loadStartupState();

  Future<String> _resolveDeviceId() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final seedParts = <String>[
        androidInfo.brand,
        androidInfo.device,
        androidInfo.fingerprint,
        androidInfo.hardware,
        androidInfo.id,
        androidInfo.manufacturer,
        androidInfo.model,
        androidInfo.product,
      ]..removeWhere((value) => value.trim().isEmpty);

      if (seedParts.isNotEmpty) {
        return _uuid.v5(
          Namespace.url.value,
          'android-device:${seedParts.join('|')}',
        );
      }
    } catch (_) {
      // Fall back below when device info is unavailable.
    }

    return _uuid.v4();
  }

  Future<void> login({required String deviceId, required String pin}) async {
    if (deviceId.trim().isEmpty || pin.trim().isEmpty) {
      emit(state.copyWith(error: 'Введите device id и PIN.'));
      return;
    }

    emit(state.copyWith(
        loading: true, message: null, error: null, navigateTo: null));
    try {
      await _client.loginCashierTerminal(
        deviceId: deviceId.trim(),
        cashierPin: pin.trim(),
      );

      final products = await _client.fetchProducts();
      for (final product in products) {
        final id = product['id']?.toString();
        final name = product['name']?.toString();
        final barcode = product['barcode']?.toString();
        if (id == null || name == null || barcode == null) continue;

        final price = double.tryParse(product['price'].toString()) ?? 0.0;
        final cost = double.tryParse(product['cost'].toString()) ?? 0.0;
        final stock = double.tryParse(product['stock'].toString()) ?? 0.0;

        await _db.upsertProduct(
          ProductTable(
            id: id,
            name: name,
            barcode: barcode,
            price: price,
            costPrice: cost,
            stock: stock,
            unit: 'шт',
            categoryId: null,
          ),
        );
      }

      emit(state.copyWith(
        loading: false,
        isFirstRun: false,
        message: 'Вход успешен. Синхронизировано товаров: ${products.length}.',
        navigateTo: '/',
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Ошибка входа: $e'));
    }
  }
}

class PlatformRegistrationState extends Equatable {
  final bool loading;
  final String? message;
  final String? error;

  const PlatformRegistrationState(
      {this.loading = false, this.message, this.error});

  PlatformRegistrationState copyWith(
      {bool? loading, String? message, String? error}) {
    return PlatformRegistrationState(
      loading: loading ?? this.loading,
      message: message,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, message, error];
}

class PlatformRegistrationCubit extends Cubit<PlatformRegistrationState> {
  final BackendV1Client _client;

  PlatformRegistrationCubit(this._client)
      : super(const PlatformRegistrationState());

  Future<void> register({
    required String organizationName,
    required String storeName,
    required String ownerUsername,
    required String ownerPassword,
  }) async {
    if (organizationName.trim().isEmpty ||
        storeName.trim().isEmpty ||
        ownerUsername.trim().isEmpty ||
        ownerPassword.trim().length < 8) {
      emit(state.copyWith(
        error:
            'Заполните все поля. Пароль владельца должен быть не менее 8 символов.',
      ));
      return;
    }

    emit(state.copyWith(loading: true, message: null, error: null));
    try {
      final response = await _client.registerPlatform(
        organizationName: organizationName.trim(),
        storeName: storeName.trim(),
        ownerUsername: ownerUsername.trim(),
        ownerPassword: ownerPassword,
      );
      final store = response['store'] as Map<String, dynamic>?;
      final storeId = store?['id'];
      emit(state.copyWith(
        loading: false,
        message: storeId != null
            ? 'Платформа зарегистрирована. Store ID: $storeId'
            : 'Платформа зарегистрирована.',
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Ошибка регистрации: $e'));
    }
  }
}

class CashRegisterSetupState extends Equatable {
  final bool loading;
  final String storeId;
  final String deviceId;
  final bool registrationCompleted;
  final String? message;
  final String? error;

  const CashRegisterSetupState({
    this.loading = false,
    this.storeId = '',
    this.deviceId = '',
    this.registrationCompleted = false,
    this.message,
    this.error,
  });

  CashRegisterSetupState copyWith({
    bool? loading,
    String? storeId,
    String? deviceId,
    bool? registrationCompleted,
    String? message,
    String? error,
  }) {
    return CashRegisterSetupState(
      loading: loading ?? this.loading,
      storeId: storeId ?? this.storeId,
      deviceId: deviceId ?? this.deviceId,
      registrationCompleted:
          registrationCompleted ?? this.registrationCompleted,
      message: message,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        storeId,
        deviceId,
        registrationCompleted,
        message,
        error,
      ];
}

class CashRegisterSetupCubit extends Cubit<CashRegisterSetupState> {
  final BackendV1Client _client;
  final BackendSession _session;

  CashRegisterSetupCubit(this._client, this._session)
      : super(const CashRegisterSetupState());

  Future<void> prefillStoreId() async {
    final storeId = await _session.getStoreId();
    if (storeId != null) {
      emit(state.copyWith(storeId: storeId.toString()));
    }
  }

  void applyScannedQr(String raw) {
    final parsedDeviceId = CashierQrPayload.parseDeviceId(raw.trim());
    if (parsedDeviceId == null) {
      emit(state.copyWith(
        registrationCompleted: false,
        error: 'Это не QR DeepPOS для устройства кассира.',
      ));
      return;
    }
    emit(state.copyWith(
      deviceId: parsedDeviceId,
      registrationCompleted: false,
      message: 'Device ID заполнен из QR.',
    ));
  }

  Future<void> register({
    required String terminalName,
    required String cashierUsername,
    required String cashierPassword,
    required String cashierPin,
  }) async {
    var parsedStoreId = await _session.getStoreId();
    if (parsedStoreId == null) {
      await _client.ensureOwnerContext();
      parsedStoreId = await _session.getStoreId();
    }
    final normalizedTerminalName = terminalName.trim();
    final deviceId = state.deviceId.trim();

    if (parsedStoreId == null ||
        normalizedTerminalName.isEmpty ||
        deviceId.isEmpty ||
        cashierUsername.trim().isEmpty ||
        cashierPassword.trim().length < 8 ||
        cashierPin.trim().isEmpty) {
      emit(state.copyWith(
        registrationCompleted: false,
        error: parsedStoreId == null
            ? 'Сначала войдите как owner и зарегистрируйте платформу.'
            : normalizedTerminalName.isEmpty
                ? 'Введите название кассы.'
                : deviceId.isEmpty
                    ? 'Сначала отсканируйте QR устройства кассира.'
                    : 'Заполните логин, пароль и PIN кассира. Пароль не менее 8 символов.',
      ));
      return;
    }

    emit(state.copyWith(
      loading: true,
      registrationCompleted: false,
      message: null,
      error: null,
    ));
    try {
      await _client.registerCashRegister(
        storeId: parsedStoreId,
        terminalName: normalizedTerminalName,
        deviceId: deviceId,
        cashierUsername: cashierUsername.trim(),
        cashierPassword: cashierPassword,
        cashierPin: cashierPin.trim(),
      );

      emit(state.copyWith(
        loading: false,
        registrationCompleted: true,
        message: 'Касса и кассир зарегистрированы.',
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        registrationCompleted: false,
        error: 'Ошибка регистрации кассы: $e',
      ));
    }
  }
}

class OpenShiftState extends Equatable {
  final bool loading;
  final String? currentShiftId;
  final String? message;
  final String? error;

  const OpenShiftState({
    this.loading = false,
    this.currentShiftId,
    this.message,
    this.error,
  });

  OpenShiftState copyWith({
    bool? loading,
    String? currentShiftId,
    String? message,
    String? error,
  }) {
    return OpenShiftState(
      loading: loading ?? this.loading,
      currentShiftId: currentShiftId ?? this.currentShiftId,
      message: message,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, currentShiftId, message, error];
}

class OpenShiftCubit extends Cubit<OpenShiftState> {
  final OpenShiftUseCase _openShiftUseCase;
  final GetCurrentShiftUseCase _getCurrentShiftUseCase;

  OpenShiftCubit(this._openShiftUseCase, this._getCurrentShiftUseCase)
      : super(const OpenShiftState());

  Future<void> loadCurrentShift() async {
    final result = await _getCurrentShiftUseCase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (shift) => emit(state.copyWith(currentShiftId: shift?.id)),
    );
  }

  Future<void> openShift({required String startBalance}) async {
    final parsedStartBalance = double.tryParse(startBalance.trim());
    if (parsedStartBalance == null || parsedStartBalance < 0) {
      emit(state.copyWith(error: 'Введите корректный стартовый баланс.'));
      return;
    }

    emit(state.copyWith(loading: true, message: null, error: null));
    try {
      final result = await _openShiftUseCase(
        OpenShiftParams(startBalance: parsedStartBalance, openedBy: 'cashier'),
      );

      final shift = result.fold((_) => null, (value) => value);
      if (shift == null) {
        final failure = result.fold((value) => value.message, (_) => '');
        emit(state.copyWith(
          loading: false,
          error: failure.isEmpty ? 'Ошибка открытия смены.' : failure,
        ));
        return;
      }

      await loadCurrentShift();
      emit(state.copyWith(
        loading: false,
        message: 'Смена открыта. Shift ID: ${shift.id}',
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Ошибка открытия смены: $e'));
    }
  }
}
