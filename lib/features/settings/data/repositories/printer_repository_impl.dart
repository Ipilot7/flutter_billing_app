import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../domain/repositories/printer_repository.dart';

class PrinterRepositoryImpl implements PrinterRepository {
  final PrinterHelper _printerHelper = PrinterHelper();
  final AppDatabase _db;

  PrinterRepositoryImpl(this._db);

  @override
  Future<List<BluetoothInfo>> scanDevices() async {
    if (await _printerHelper.checkPermission()) {
      return await _printerHelper.getBondedDevices();
    }
    throw Exception('Bluetooth permission denied');
  }

  @override
  Future<bool> connect(String macAddress) async {
    return await _printerHelper.connect(macAddress);
  }

  @override
  Future<bool> disconnect() async {
    return await _printerHelper.disconnect();
  }

  @override
  Future<String?> getSavedPrinterMac() async {
    return await _db.getSetting('printer_mac');
  }

  @override
  Future<String?> getSavedPrinterName() async {
    return await _db.getSetting('printer_name');
  }

  @override
  Future<void> savePrinterData(String mac, String name) async {
    await _db.saveSetting('printer_mac', mac);
    await _db.saveSetting('printer_name', name);
  }

  @override
  Future<void> clearPrinterData() async {
    await _db.deleteSetting('printer_mac');
    await _db.deleteSetting('printer_name');
  }

  @override
  Future<void> testPrint(String shopName) async {
    await _printerHelper
        .printText("Test Print\n\n$shopName\n\n----------------\n\n");
  }
}
