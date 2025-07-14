import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class ViewJson extends StatefulWidget {
  const ViewJson({super.key});

  @override
  State<ViewJson> createState() => _ViewJsonState();
}

class _ViewJsonState extends State<ViewJson> {
  List<Map<String, dynamic>> jsonData = [];
  List<String> headers = [];

  Future<void> pickJsonFile() async {
    try {
      final typeGroup = XTypeGroup(
        label: 'json',
        extensions: ['json'],
      );

      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        final contents = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(contents);

        if (decoded.isNotEmpty && decoded.first is Map) {
          setState(() {
            jsonData = decoded.cast<Map<String, dynamic>>();
            headers = jsonData.first.keys.toList();
          });
        } else {
          _showError("⚠️ Invalid JSON: Not an array of objects");
        }
      }
    } catch (e) {
      _showError("❌ Error reading JSON: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("JSON Viewer")),
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: pickJsonFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("Pick JSON File"),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: jsonData.isEmpty
                ? const Center(child: Text("No data loaded"))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: headers
                          .map((h) => DataColumn(label: Text(h.toUpperCase())))
                          .toList(),
                      rows: jsonData.map((row) {
                        return DataRow(
                          cells: headers.map((key) {
                            return DataCell(Text(row[key]?.toString() ?? ""));
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
