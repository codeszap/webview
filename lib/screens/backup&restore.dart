import 'package:flutter/material.dart';
import 'package:webview/db/backup_Restore_Helper.dart';
import 'package:webview/widgets/common_appbar.dart';
import 'package:webview/widgets/common_button.dart';
import 'package:webview/widgets/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class BackupRestore extends StatefulWidget {
  const BackupRestore({super.key});

  @override
  State<BackupRestore> createState() => _BackupRestoreState();
}

class _BackupRestoreState extends State<BackupRestore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(title: "Backup & Restore"),
      drawer: CommonDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonButton(
                title: "Backup",
                tap: () async {
                  BackupRestoreHelper.backupToFolder(context, toDocuments: false);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("✅ Backup done")));
                },
              ),
              SizedBox(height: 10),
              CommonButton(
                title: "Restore",
                backgroundColor: Colors.red,
                tap: () async {
                  await BackupRestoreHelper.restoreDatabase(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("✅ Restore done, restart app")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
