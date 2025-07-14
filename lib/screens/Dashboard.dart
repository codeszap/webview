import 'package:flutter/material.dart';
import 'package:webview/db/database_helper.dart';
import 'package:webview/screens/create_app.dart';
import 'package:webview/screens/webview.dart';
import 'package:webview/widgets/common_appbar.dart';
import 'package:webview/widgets/common_drawer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> viewData = [];
  List<Map<String, dynamic>> allData = [];
  TextEditingController searchController = TextEditingController();

  Future<void> loadviewData([String query = '']) async {
    final data = await db.getNotes();
    allData = data;
    if (query.isEmpty) {
      viewData = data;
    } else {
      viewData = data.where((note) {
        final title = note['title'].toLowerCase();
        final url = note['url'].toLowerCase();
        final icon = note['icon'].toLowerCase();
        final search = query.toLowerCase();
        return title.contains(search) ||
            url.contains(search) ||
            icon.contains(search);
      }).toList();
    }
    setState(() {});
  }


Future<void> confirmAndDelete(BuildContext context, int id) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Confirm Delete"),
      content: Text("Are you sure you want to delete this entry?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    await db.deleteNote(id);
ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Deleted Successfully")));
    await loadviewData(); // reload updated list
  }
}



  @override
  void initState() {
    super.initState();
    loadviewData();
    searchController.addListener(() {
      loadviewData(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(title: "Dashboard"),
      drawer: CommonDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Navigator.push(context,  MaterialPageRoute(builder: (context) => CreateApp()));
        },
        icon: Icon(Icons.add_circle),
        label: Text("Add"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          FocusScope.of(context).unfocus(); // Hide keyboard
                        },
                      )
                    : null,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: viewData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No Data", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: viewData.length,
                    itemBuilder: (context, index) {
                      final note = viewData[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => webview(url: note['url']),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ListTile(
                              title: Text(
                                note['title'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note['url'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(note['icon']),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  // await db.deleteNote(note['id']);
                                  // loadviewData(searchController.text);
                                  confirmAndDelete(context,note['id']);
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
