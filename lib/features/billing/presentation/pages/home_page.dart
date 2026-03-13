import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../shift/presentation/bloc/shift_bloc.dart';
import '../../../shift/presentation/bloc/shift_state.dart';
import '../../../shift/presentation/bloc/shift_event.dart';
import '../../../sales/presentation/bloc/analytics_bloc.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/network/backend_session.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/cart_item.dart';

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

  bool _isCameraOn = false;
  bool _isFlashOn = false;

  // Cooldown mapping to prevent rapid firing of the same barcode
  final Map<String, DateTime> _lastScanTimes = {};

  bool _backendConfigured = false;
  bool _backendAuthenticated = false;
  int? _backendTerminalId;
  int? _backendShiftId;
  int _backendLocalProductCount = 0;

  @override
  void initState() {
    super.initState();
    _isCameraOn = true;
    _refreshAnalytics(); // Initial load for today's stats
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
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    final now = DateTime.now();

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final rawValue = barcode.rawValue!;

        // Cooldown logic: 2 seconds per identical barcode
        if (_lastScanTimes.containsKey(rawValue)) {
          final lastScan = _lastScanTimes[rawValue]!;
          if (now.difference(lastScan).inSeconds < 2) {
            continue;
          }
        }

        _lastScanTimes[rawValue] = now;

        // Vibrate
        final canVibrate = await Vibrate.canVibrate;
        if (canVibrate) {
          Vibrate.feedback(FeedbackType.success);
        }

        if (mounted) {
          context.read<BillingBloc>().add(ScanBarcodeEvent(rawValue));
        }
        break; // Process one barcode at a time per frame
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
            listener: (context, state) {
              // Cart cleared usually means sale completed or manually cleared
              _refreshAnalytics();
            },
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
          BlocListener<ShiftBloc, ShiftState>(
            listener: (context, state) {
              // We no longer toggle camera based on shift status.
            },
          ),
        ],
        child: Stack(
          children: [
            // SCANNER VIEW (TOP 50%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: _buildScannerSection(),
            ),

            // BOTTOM PANEL (BOTTOM 50% + OVERLAP)
            Positioned(
              top: (MediaQuery.of(context).size.height * 0.4) - 24, // overlap
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomPanel(),
            ),
          ],
        ),
      ),
      bottomSheet:
          BlocBuilder<BillingBloc, BillingState>(builder: (context, state) {
        return PrimaryButton(
          onPressed: state.cartItems.isEmpty
              ? null
              : () async {
                  Future.microtask(() => _scannerController.stop());
                  await context.push('/checkout');
                  if (_isCameraOn && mounted) {
                    Future.microtask(() => _scannerController.start());
                  }
                },
          icon: Icons.payment,
          label: AppLocalizations.of(context)!.reviewOrder,
        );
      }),
    );
  }

  Widget _buildScannerSection() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraOn)
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            )
          else
            _buildCameraOffState(),

          // Shift Status (Top Left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: BlocBuilder<ShiftBloc, ShiftState>(
              builder: (context, state) {
                final isOpen = state is ShiftLoaded && state.hasOpenShift;
                return GestureDetector(
                  onTap: () => _showShiftDialog(context, isOpen),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isOpen ? Colors.green : Colors.orange)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isOpen ? Icons.lock_open : Icons.lock,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          isOpen
                              ? AppLocalizations.of(context)!.statusOpen
                              : AppLocalizations.of(context)!.statusClosed,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_backendConfigured)
            Positioned(
              top: MediaQuery.of(context).padding.top + 58,
              left: 16,
              child: _buildBackendStatusChip(),
            ),
          // Controls & Actions Sidebar (Right Side)
          Positioned(
            top: MediaQuery.of(context).padding.top + 2,
            right: 10,
            bottom: 50, // Allow it to stretch or align towards bottom
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // CAMERA CONTROLS
                if (_isCameraOn)
                  _buildOverlayButton(
                    icon:
                        _isFlashOn ? Icons.flashlight_off : Icons.flashlight_on,
                    onPressed: () {
                      setState(() => _isFlashOn = !_isFlashOn);
                      _scannerController.toggleTorch();
                    },
                  ),
                _buildOverlayButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  onPressed: () {
                    setState(() => _isCameraOn = !_isCameraOn);
                    if (_isCameraOn) {
                      Future.microtask(() => _scannerController.start());
                    } else {
                      Future.microtask(() => _scannerController.stop());
                    }
                  },
                ),
                _buildOverlayButton(
                  icon: Icons.search,
                  label: AppLocalizations.of(context)!.search,
                  color: Colors.blue,
                  onPressed: () async {
                    Future.microtask(() => _scannerController.stop());
                    await context.push('/products/search');
                    if (_isCameraOn && mounted) {
                      Future.microtask(() => _scannerController.start());
                    }
                  },
                ),
                // _buildOverlayButton(
                //   icon: Icons.inventory_2_outlined,
                //   label: AppLocalizations.of(context)!.stockManagement,
                //   color: Colors.orange,
                //   onPressed: () async {
                //     Future.microtask(() => _scannerController.stop());
                //     await context.push('/products/inventory');
                //     if (_isCameraOn && mounted) {
                //       Future.microtask(() => _scannerController.start());
                //     }
                //   },
                // ),
                // _buildOverlayButton(
                //   icon: Icons.history,
                //   label: AppLocalizations.of(context)!.salesHistory,
                //   color: Colors.purple,
                //   onPressed: () async {
                //     Future.microtask(() => _scannerController.stop());
                //     await context.push('/sales');
                //     if (_isCameraOn && mounted) {
                //       Future.microtask(() => _scannerController.start());
                //     }
                //   },
                // ),
                // _buildOverlayButton(
                //   icon: Icons.bar_chart,
                //   label: AppLocalizations.of(context)!.analytics,
                //   color: Colors.teal,
                //   onPressed: () async {
                //     Future.microtask(() => _scannerController.stop());
                //     await context.push('/analytics');
                //     if (_isCameraOn && mounted) {
                //       Future.microtask(() => _scannerController.start());
                //     }
                //   },
                // ),

                _buildOverlayButton(
                  icon: Icons.settings,
                  label: AppLocalizations.of(context)!.settings,
                  color: const Color(0xFF64748B),
                  onPressed: () async {
                    Future.microtask(() => _scannerController.stop());
                    await context.push('/settings');
                    await _loadBackendStatus();
                    if (_isCameraOn && mounted) {
                      Future.microtask(() => _scannerController.start());
                    }
                  },
                ),
              ],
            ),
          ),

          // Central Overlay Bounding Box
          if (_isCameraOn)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Corners
                    _buildCorner(Alignment.topLeft),
                    _buildCorner(Alignment.topRight),
                    _buildCorner(Alignment.bottomLeft),
                    _buildCorner(Alignment.bottomRight),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraOffState() {
    return Container(
      color: const Color(0xFF1E293B), // slate-800
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF334155), // slate-700
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child:
                const Icon(Icons.videocam_off, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.cameraOff,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              AppLocalizations.of(context)!.cameraOffDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.videocam),
            label: Text(AppLocalizations.of(context)!.turnOnCamera,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() => _isCameraOn = true);
              _scannerController.start();
            },
          )
        ],
      ),
    );
  }

  Widget _buildOverlayButton(
      {required IconData icon,
      required VoidCallback onPressed,
      Color? color,
      String? label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color?.withValues(alpha: 0.9) ?? Colors.black45,
            shape: BoxShape.circle,
            boxShadow: [
              if (color != null)
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
            ],
            border: Border.all(color: Colors.white24),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 22),
            onPressed: onPressed,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                    color: Colors.black54, blurRadius: 4, offset: Offset(0, 1))
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            left: (alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            right: (alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 15, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        children: [
          // Drag handle indicator
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Today's quick stats bar
          _buildTodayStats(),
          BlocBuilder<BillingBloc, BillingState>(
            builder: (context, state) {
              final totalItems =
                  state.cartItems.fold<double>(0, (sum, i) => sum + i.quantity);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.scannedItems,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Text(
                            AppLocalizations.of(context)!
                                .totalItems(totalItems.toInt()),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            AppLocalizations.of(context)!
                                .totalAmount
                                .toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.2)),
                        Text(
                          state.totalAmount.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),

          // List View
          Expanded(
            child: Stack(children: [
              BlocBuilder<BillingBloc, BillingState>(
                builder: (context, state) {
                  if (state.cartItems.isEmpty) {
                    return _buildEmptyCart();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 16, bottom: 100),
                    itemCount: state.cartItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return _buildCartItemCard(context, item);
                    },
                  );
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is! AnalyticsLoaded) {
          return const SizedBox(height: 10);
        }

        final l = AppLocalizations.of(context)!;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              _todayStatItem(
                context,
                icon: Icons.receipt_long,
                label: l.transactions,
                value: state.sales.length.toString(),
              ),
              Container(width: 1, height: 24, color: Colors.grey[200]),
              _todayStatItem(
                context,
                icon: Icons.payments,
                label: l.revenue,
                value: '${l.currency} ${state.totalRevenue.toInt()}',
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackendStatusChip() {
    final hasReadySession = _backendAuthenticated &&
        _backendTerminalId != null &&
        _backendShiftId != null;

    final backgroundColor = hasReadySession
        ? Colors.teal.withValues(alpha: 0.9)
        : Colors.deepOrange.withValues(alpha: 0.9);

    final statusText = hasReadySession
        ? 'Backend ready · shift #$_backendShiftId'
        : 'Backend set, shift not open';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_done, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            '$statusText · products $_backendLocalProductCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayStatItem(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      bool isBold = false}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
                  color: isBold ? AppTheme.primaryColor : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.shopping_basket,
                  size: 40, color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.listIsEmpty,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                AppLocalizations.of(context)!.scannedItemsAppear,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CartItem item,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 1,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context)!.currency} ${item.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _circularIconButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (item.quantity > 1) {
                        context.read<BillingBloc>().add(UpdateQuantityEvent(
                            item.product.id, item.quantity - 1.0));
                      } else {
                        context
                            .read<BillingBloc>()
                            .add(RemoveProductFromCartEvent(item.product.id));
                      }
                    }),
                SizedBox(
                  width: 32,
                  child: Text(
                    item.quantity % 1 == 0
                        ? item.quantity.toInt().toString()
                        : item.quantity.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _circularIconButton(
                    icon: Icons.add,
                    onPressed: () {
                      context.read<BillingBloc>().add(UpdateQuantityEvent(
                          item.product.id, item.quantity + 1.0));
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
    );
  }

  void _showShiftDialog(BuildContext context, bool isOpen) {
    if (isOpen) {
      final shiftBloc = context.read<ShiftBloc>();
      final currentShift = shiftBloc.currentShift;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.closeShift),
          content: Text(
            '${AppLocalizations.of(context)!.startBalance}: ${AppLocalizations.of(context)!.currency} ${currentShift?.startBalance.toStringAsFixed(2) ?? "0"}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final controller = TextEditingController();
                showDialog(
                  context: ctx,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.endBalance),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.enterEndBalance,
                        prefixText:
                            '${AppLocalizations.of(context)!.currency} ',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final balance = double.tryParse(controller.text) ?? 0;
                          context
                              .read<ShiftBloc>()
                              .add(CloseShiftEvent(endBalance: balance));
                          Navigator.pop(context);
                          Navigator.pop(ctx);
                        },
                        child: Text(AppLocalizations.of(context)!.close),
                      ),
                    ],
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.closeShift),
            ),
          ],
        ),
      );
    } else {
      final startBalanceController = TextEditingController(text: '0');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.openShift),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.startBalance,
              prefixText: '${AppLocalizations.of(context)!.currency} ',
            ),
            controller: startBalanceController,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final balance =
                    double.tryParse(startBalanceController.text) ?? 0;
                context.read<ShiftBloc>().add(OpenShiftEvent(
                      startBalance: balance,
                      openedBy: AppLocalizations.of(context)!.cashier,
                    ));
                Navigator.pop(ctx);
              },
              child: Text(AppLocalizations.of(context)!.open),
            ),
          ],
        ),
      );
    }
  }

  // A floating Details/Checkout Button at the very bottom
  // Added a Stack wrapper below to overlay this button
}
