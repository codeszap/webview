import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview/widgets/common_appbar.dart';
import 'package:webview/widgets/common_drawer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SeeIndexeddb extends StatefulWidget {
  const SeeIndexeddb({super.key});

  @override
  State<SeeIndexeddb> createState() => _SeeIndexeddbState();
}

class _SeeIndexeddbState extends State<SeeIndexeddb> {
  late final WebViewController _controller;
  String? _indexedDbData;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse("https://codeszap.github.io/saf/mr.html")); 
  }

  Future<void> fetchAllMeditationEntries() async {
    final jsScript = """
      new Promise((resolve, reject) => {
        const request = indexedDB.open('MeditationDB');
        request.onsuccess = function(event) {
          const db = event.target.result;
          const transaction = db.transaction('entries', 'readonly');
          const store = transaction.objectStore('entries');
          const getAllRequest = store.getAll();
          
          getAllRequest.onsuccess = function() {
            resolve(JSON.stringify(getAllRequest.result));
          };
          
          getAllRequest.onerror = function() {
            reject("Failed to fetch entries.");
          };
        };
        
        request.onerror = function() {
          reject("Failed to open MeditationDB.");
        };
      });
    """;

    try {
      final result = await _controller.runJavaScriptReturningResult(jsScript);

      setState(() {
        _indexedDbData = result.toString();
      });

      print("Data from IndexedDB: $_indexedDbData");

    } catch (e) {
      print("IndexedDB read error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CommonAppbar(title: "See IndexedDB Data"),
      drawer: CommonDrawer(),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          ElevatedButton(
            onPressed: fetchAllMeditationEntries,
            child: const Text("Fetch IndexedDB Entries"),
          ),
          if (_indexedDbData != null)
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Data from DB:"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_indexedDbData ?? ""),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
