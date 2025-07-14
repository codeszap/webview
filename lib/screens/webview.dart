import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview/db/database_helper.dart';
import 'package:webview/widgets/common_appbar.dart';
import 'package:webview/widgets/common_drawer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class webview extends StatefulWidget {
  final String? url;
  const webview({super.key, this.url = ""});

  @override
  State<webview> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<webview> with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 🔁 Lifecycle observer
    _initWebview(); // 🔧 setup webview
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ❌ remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.reload(); // 🔁 reload on resume
    }
  }

  void _initWebview() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      ..addJavaScriptChannel(
        'ImageChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          final base64Data = message.message.split(',').last;
          final bytes = base64Decode(base64Data);

          final status = await Permission.storage.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ Storage permission denied")),
            );
            return;
          }

          final pathFromDb = await DatabaseHelper().getSettingValue('download path');
          if (pathFromDb == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ Download path not found in settings")),
            );
            return;
          }

          final directory = Directory(pathFromDb);
          final file = File('${directory.path}/capture_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(bytes);

          print("✅ Image saved to: ${file.path}");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Saved to: ${file.path}')),
          );
        },
      )

      ..addJavaScriptChannel(
        'SaveDataChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final decoded = jsonDecode(message.message);
            final String formName = decoded['form'];
            final dynamic formData = decoded['data'];

            final pathFromDb = await DatabaseHelper().getSettingValue('download path');
            if (pathFromDb == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("❌ Download path not found in settings")),
              );
              return;
            }

            final dir = Directory(pathFromDb);
            final file = File('${dir.path}/$formName.json');

            await file.writeAsString(jsonEncode(formData), flush: true);

            print("✅ Saved $formName to: ${file.path}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("✅ $formName saved")),
            );
          } catch (e) {
            print("❌ Failed to save: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ Failed to save form data")),
            );
          }
        },
      )

      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            if (request.url.contains("example.com")) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            print('❌ Web resource error: $error');
          },
        ),
      )

      ..loadRequest(Uri.parse(widget.url!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(title: "Webview"),
      drawer: CommonDrawer(),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await _controller.reload();
            },
            child: SafeArea(
              child: WebViewWidget(controller: _controller),
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
