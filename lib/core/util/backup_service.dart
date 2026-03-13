import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:billing_app/core/data/app_database.dart';
import 'package:flutter/foundation.dart';

class BackupService {
  final AppDatabase _database;

  BackupService(this._database);

  Future<void> createBackup() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'db.sqlite'));

      if (await dbFile.exists()) {
        final date = DateTime.now()
            .toIso8601String()
            .replaceAll(':', '-')
            .split('.')
            .first;
        final backupFileName = 'billing_backup_$date.sqlite';
        final tempDir = await getTemporaryDirectory();
        final backupFile =
            await dbFile.copy(p.join(tempDir.path, backupFileName));

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(backupFile.path)],
            subject: 'Billing App Database Backup',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
    }
  }

  Future<bool> restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // SQLite files can have various extensions or none
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);

        // Basic validation: check if it's a sqlite file (optional but recommended)
        // For now, we'll just try to copy it.

        final dbFolder = await getApplicationDocumentsDirectory();
        final dbPath = p.join(dbFolder.path, 'db.sqlite');

        // Close database before overwriting
        await _database.close();

        // Copy picked file to database location
        await pickedFile.copy(dbPath);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      rethrow;
    }
  }
}
