import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'backend_status_chip.dart';

class ScannerSection extends StatelessWidget {
  final bool isCameraOn;
  final bool isFlashOn;
  final MobileScannerController controller;
  final Function(BarcodeCapture) onDetect;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleFlash;
  final VoidCallback onSearch;
  final VoidCallback onSettings;
  final VoidCallback onShiftTap;
  final bool isShiftOpen;
  
  // Backend status props
  final bool backendConfigured;
  final bool backendAuthenticated;
  final int? backendTerminalId;
  final int? backendShiftId;
  final int backendLocalProductCount;

  const ScannerSection({
    super.key,
    required this.isCameraOn,
    required this.isFlashOn,
    required this.controller,
    required this.onDetect,
    required this.onToggleCamera,
    required this.onToggleFlash,
    required this.onSearch,
    required this.onSettings,
    required this.onShiftTap,
    required this.isShiftOpen,
    required this.backendConfigured,
    required this.backendAuthenticated,
    this.backendTerminalId,
    this.backendShiftId,
    required this.backendLocalProductCount,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isCameraOn)
            MobileScanner(
              controller: controller,
              onDetect: onDetect,
            )
          else
            _buildCameraOffState(context),

          // Shift Status (Top Left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: onShiftTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isShiftOpen ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isShiftOpen ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isShiftOpen ? Icons.lock_open : Icons.lock,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      isShiftOpen ? l.statusOpen : l.statusClosed,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (backendConfigured)
            Positioned(
              top: MediaQuery.of(context).padding.top + 58,
              left: 16,
              child: BackendStatusChip(
                isAuthenticated: backendAuthenticated,
                terminalId: backendTerminalId,
                shiftId: backendShiftId,
                localProductCount: backendLocalProductCount,
              ),
            ),

          // Controls & Actions Sidebar (Right Side)
          Positioned(
            top: MediaQuery.of(context).padding.top + 2,
            right: 10,
            bottom: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCameraOn)
                  _buildOverlayButton(
                    icon: isFlashOn ? Icons.flashlight_off : Icons.flashlight_on,
                    onPressed: onToggleFlash,
                  ),
                _buildOverlayButton(
                  icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                  onPressed: onToggleCamera,
                ),
                _buildOverlayButton(
                  icon: Icons.search,
                  label: l.search,
                  color: Colors.blue,
                  onPressed: onSearch,
                ),
                _buildOverlayButton(
                  icon: Icons.settings,
                  label: l.settings,
                  color: const Color(0xFF64748B),
                  onPressed: onSettings,
                ),
              ],
            ),
          ),

          // Central Overlay Bounding Box
          if (isCameraOn)
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

  Widget _buildCameraOffState(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
            child: const Icon(Icons.videocam_off, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            l.cameraOff,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l.cameraOffDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.videocam),
            label: Text(l.turnOnCamera, style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: onToggleCamera,
          )
        ],
      ),
    );
  }

  Widget _buildOverlayButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    String? label,
  }) {
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
                Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1))
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
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
