import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview/screens/backup&restore.dart';
import 'package:webview/screens/create_app.dart';
import 'package:webview/screens/gallery.dart';
import 'package:webview/screens/see_indexedDb.dart';
import 'package:webview/screens/setting.dart';
import 'package:webview/screens/view_json.dart';
import 'package:webview/screens/webview.dart';
import 'package:webview/screens/Dashboard.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

@override
Widget build(BuildContext context) {
  return Drawer(
    backgroundColor: Colors.black,
    child: Column(
      children: [
        SizedBox(
          height: 100,
          child: DrawerHeader(
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apps_outlined, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Webview", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                    (Route<dynamic> route) => false,
                  );
                },
                leading: Icon(Icons.dashboard, color: Colors.white.withOpacity(0.7)),
                title: Text("Dashboard", style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => CreateApp()),
                    (Route<dynamic> route) => false,
                  );
                },
                leading: Icon(Icons.create, color: Colors.white.withOpacity(0.7)),
                title: Text("Create", style: TextStyle(color: Colors.white)),
              ),
               ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SeeIndexeddb()),
                    (Route<dynamic> route) => false,
                  );
                },
                leading: Icon(Icons.data_saver_off_sharp, color: Colors.white.withOpacity(0.7)),
                title: Text("Index Db", style: TextStyle(color: Colors.white)),
              ),
               ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => BackupRestore()),
                    (Route<dynamic> route) => false,
                  );
                },
                leading: Icon(Icons.backup, color: Colors.white.withOpacity(0.7)),
                title: Text("Backup & Restore", style: TextStyle(color: Colors.white)),
              ),
                ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Setting()),
                    (Route<dynamic> route) => false,
                  );
                },
                leading: Icon(Icons.settings, color: Colors.white.withOpacity(0.7)),
                title: Text("Setting", style: TextStyle(color: Colors.white)),
              ),
               ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Gallery()),
                    (Route<dynamic> route) => false,
                  );
                },
                leading: Icon(Icons.photo_album, color: Colors.white.withOpacity(0.7)),
                title: Text("Gallery", style: TextStyle(color: Colors.white)),
              ),
              //  ListTile(
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(builder: (context) => ViewJson()),
              //       (Route<dynamic> route) => false,
              //     );
              //   },
              //   leading: Icon(Icons.data_array, color: Colors.white.withOpacity(0.7)),
              //   title: Text("View Json", style: TextStyle(color: Colors.white)),
              // ),
              ListTile(
                onTap: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
                leading: Icon(Icons.logout, color: Colors.white.withOpacity(0.7)),
                title: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
}
}
