import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview/db/database_helper.dart';
import 'package:webview/widgets/common_appbar.dart';
import 'package:webview/widgets/common_button.dart';
import 'package:webview/widgets/common_drawer.dart';
import 'package:webview/widgets/common_textfield.dart';

class CreateApp extends StatefulWidget {
  const CreateApp({super.key});

  @override
  State<CreateApp> createState() => _CreateAppState();
}

class _CreateAppState extends State<CreateApp> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> notes = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    notes = await db.getNotes();
    setState(() {});
  }

  Future<String?> verifyEntry() async {
    if (nameController.text.trim() == "") {
      return "Fill Name Field";
    }
    if (urlController.text.trim() == "") {
      return "Fill Url Field";
    }
    // if (iconController.text.trim() == "") {
    //   return "Fill Icon Field";
    // }
    return null;
  }

  Future<void> addData() async {
    String? errorText = await verifyEntry();

    if (errorText == null) {
      int id = await db.insertNote(
        nameController.text,
        urlController.text,
        iconController.text,
      );

      if (id == 0) {
        Fluttertoast.showToast(
          msg: id.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: id.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        await clearData();
      }

      await loadData();
      
    } else {
      Fluttertoast.showToast(
        msg: errorText,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> clearData() async {
    nameController.clear();
    urlController.clear();
    iconController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(title: "Create"),
      drawer: CommonDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CommonTextfield(
              title: "Name",
              hintText: "Enter App Name",
              controller: nameController,
            ),
            CommonTextfield(
              title: "Url",
              hintText: "Enter Url",
              controller: urlController,
            ),
            CommonTextfield(
              title: "Icon",
              hintText: "Enter Icon",
              controller: iconController,
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CommonButton(
                    title: "Add",
                    backgroundColor: Colors.green,
                    textcolor: Colors.white,
                    tap: () async {
                      await addData();
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: CommonButton(
                    title: "Clear",
                    backgroundColor: Colors.red,
                    textcolor: Colors.white,
                    tap: () {
                      clearData();
                    },
                  ),
                ),
              ],
            ),
        
          ],
        ),
      ),
  
    );
  }
}

//Name
//url
//icons
//save
