import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import 'package:path/path.dart' as p;
import 'package:webview/db/database_helper.dart';

class BackupRestoreHelper {
  static Future<String> getDbPath() async {
    final dbFolder = await getDatabasesPath();
    return p.join(dbFolder, 'htmlWebview.db');
  }

  static Future<void> backupToFolder(
    BuildContext context, {
    bool toDocuments = false,
  }) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Storage permission denied")));
      return;
    }

    final dbPath = await getDbPath();
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Database file not found")));
      return;
    }

    final dbBytes = await dbFile.readAsBytes();
    final fileName =
        'htmlWebview_backup_${DateTime.now().millisecondsSinceEpoch}.db';

    // Get Folder (Downloads or Documents)
    Directory? targetDir;
    if (toDocuments) {
      targetDir = await getApplicationDocumentsDirectory(); // Internal docs
    } else {
      final pathFromDb = await DatabaseHelper().getSettingValue(
        'download path',
      );

      print("downlaod path: $pathFromDb");
      if (pathFromDb == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Download path not found in settings"),
          ),
        );
        return;
      }

      targetDir = Directory(pathFromDb);
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final fullPath = p.join(targetDir.path, fileName);
    final newFile = await File(fullPath).writeAsBytes(dbBytes);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("✅ Backup Saved"),
          content: Text("File saved at:\n${newFile.path}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  static Future<void> restoreDatabase(BuildContext context) async {
    final permission = await Permission.storage.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Storage permission denied")));
      return;
    }

    // Launch Android file picker
    final pickedFilePath = await FlutterFileDialog.pickFile(
      params: OpenFileDialogParams(
        dialogType: OpenFileDialogType.document,
        fileExtensionsFilter: ['db'],
      ),
    );

    if (pickedFilePath != null) {
      final selectedFile = File(pickedFilePath);
      final appDbPath = await getDbPath();

      // Replace DB file
      await selectedFile.copy(appDbPath);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("✅ Restored"),
            content: Text("Database restored from:\n$pickedFilePath"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ No file selected")));
    }
  }
}
