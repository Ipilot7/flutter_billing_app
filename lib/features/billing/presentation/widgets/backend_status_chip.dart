import 'package:flutter/material.dart';

class BackendStatusChip extends StatelessWidget {
  final bool isAuthenticated;
  final int? terminalId;
  final int? shiftId;
  final int localProductCount;

  const BackendStatusChip({
    super.key,
    required this.isAuthenticated,
    required this.terminalId,
    required this.shiftId,
    required this.localProductCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasReadySession = isAuthenticated && terminalId != null && shiftId != null;

    final backgroundColor = hasReadySession
        ? Colors.teal.withValues(alpha: 0.9)
        : Colors.deepOrange.withValues(alpha: 0.9);

    final statusText = hasReadySession
        ? 'Backend ready · shift #$shiftId'
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
          Flexible(
            child: Text(
              '$statusText · products $localProductCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
