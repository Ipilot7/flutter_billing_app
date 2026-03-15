import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:billing_app/core/network/cashier_qr_payload.dart';

class CashierDeviceQrPage extends StatelessWidget {
  final String deviceId;

  const CashierDeviceQrPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final payload = CashierQrPayload.build(deviceId: deviceId);

    return Scaffold(
      appBar: AppBar(title: const Text('QR устройства кассира')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Покажите этот QR владельцу для быстрой регистрации кассы',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: PrettyQrView.data(
                  data: payload,
                  decoration: const PrettyQrDecoration(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'QR поддерживается только форматом DeepPOS.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
