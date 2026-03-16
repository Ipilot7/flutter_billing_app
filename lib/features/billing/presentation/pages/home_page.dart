import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../shift/presentation/bloc/shift_bloc.dart';
import '../../../shift/presentation/bloc/shift_state.dart';
import '../../../sales/presentation/bloc/analytics_bloc.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/network/backend_session.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/scanner_section.dart';
import '../widgets/cart_bottom_panel.dart';
import '../../../shift/presentation/widgets/shift_dialog_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );
  final ValueNotifier<int> _uiTick = ValueNotifier<int>(0);

  bool _isCameraOn = true;
  bool _isFlashOn = false;

  final Map<String, DateTime> _lastScanTimes = {};

  bool _backendConfigured = false;
  bool _backendAuthenticated = false;
  int? _backendTerminalId;
  int? _backendShiftId;
  int _backendLocalProductCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshAnalytics();
    _loadBackendStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scannerController.start();
    });
  }

  Future<void> _loadBackendStatus() async {
    final session = sl<BackendSession>();
    final db = sl<AppDatabase>();

    final baseUrl = await session.getBaseUrl();
    final token = await session.getAccessToken();
    final terminalId = await session.getTerminalId();
    final shiftId = await session.getCurrentShiftId();
    final productCount = await db.countProducts();

    if (!mounted) return;

    setState(() {
      _backendConfigured = baseUrl != null && baseUrl.trim().isNotEmpty;
      _backendAuthenticated = token != null && token.trim().isNotEmpty;
      _backendTerminalId = terminalId;
      _backendShiftId = shiftId;
      _backendLocalProductCount = productCount;
    });
  }

  void _refreshAnalytics() {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    context.read<AnalyticsBloc>().add(LoadAnalyticsEvent(from: from, to: to));
  }

  @override
  void dispose() {
    _uiTick.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    final now = DateTime.now();

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final rawValue = barcode.rawValue!;

        if (_lastScanTimes.containsKey(rawValue)) {
          final lastScan = _lastScanTimes[rawValue]!;
          if (now.difference(lastScan).inSeconds < 2) continue;
        }

        _lastScanTimes[rawValue] = now;

        final canVibrate = await Vibrate.canVibrate;
        if (canVibrate) {
          Vibrate.feedback(FeedbackType.success);
        }

        if (mounted) {
          context.read<BillingBloc>().add(ScanBarcodeEvent(rawValue));
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<BillingBloc, BillingState>(
            listenWhen: (previous, current) =>
                previous.cartItems.isNotEmpty && current.cartItems.isEmpty,
            listener: (context, state) => _refreshAnalytics(),
          ),
          BlocListener<BillingBloc, BillingState>(
            listenWhen: (previous, current) =>
                previous.error != current.error && current.error != null,
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
        child: Stack(
          children: [
            // SCANNER VIEW (TOP 40%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: BlocBuilder<ShiftBloc, ShiftState>(
              buildWhen: (previous, current) =>
                  previous.runtimeType != current.runtimeType ||
                  (previous is ShiftLoaded &&
                      current is ShiftLoaded &&
                      previous.hasOpenShift != current.hasOpenShift),
              builder: (context, state) {
                final isShiftOpen = state is ShiftLoaded && state.hasOpenShift;
                return ScannerSection(
                  isCameraOn: _isCameraOn,
                  isFlashOn: _isFlashOn,
                  controller: _scannerController,
                  onDetect: _onDetect,
                  onToggleCamera: () {
                    setState(() => _isCameraOn = !_isCameraOn);
                    if (_isCameraOn) {
                      _scannerController.start();
                    } else {
                      _scannerController.stop();
                    }
                  },
                  onToggleFlash: () {
                    setState(() => _isFlashOn = !_isFlashOn);
                    _scannerController.toggleTorch();
                  },
                  onSearch: () async {
                    _scannerController.stop();
                    await context.push('/products/search');
                    if (_isCameraOn && mounted) _scannerController.start();
                  },
                  onSettings: () async {
                    _scannerController.stop();
                    await context.push('/settings');
                    await _loadBackendStatus();
                    if (_isCameraOn && mounted) _scannerController.start();
                  },
                  onShiftTap: () =>
                      ShiftDialogHelper.showShiftDialog(context, isShiftOpen),
                  isShiftOpen: isShiftOpen,
                  backendConfigured: _backendConfigured,
                  backendAuthenticated: _backendAuthenticated,
                  backendTerminalId: _backendTerminalId,
                  backendShiftId: _backendShiftId,
                  backendLocalProductCount: _backendLocalProductCount,
                );
              },
            ),
          ),

          // BOTTOM PANEL (BOTTOM 60% + OVERLAP)
          Positioned(
            top: (MediaQuery.of(context).size.height * 0.4) - 24,
            left: 0,
            right: 0,
            bottom: 0,
            child: const CartBottomPanel(),
          ),
        ],
      ),
    ),
    bottomSheet: BlocBuilder<BillingBloc, BillingState>(
      buildWhen: (previous, current) =>
          previous.cartItems.isEmpty != current.cartItems.isEmpty,
      builder: (context, state) {
        return PrimaryButton(
          onPressed: state.cartItems.isEmpty
              ? null
              : () async {
                  _scannerController.stop();
                  await context.push('/checkout');
                  if (_isCameraOn && mounted) _scannerController.start();
                },
          icon: Icons.payment,
          label: AppLocalizations.of(context)!.reviewOrder,
        );
      },
    ),
    );
  }
}
