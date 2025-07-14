import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview/db/database_helper.dart';
import 'package:webview/widgets/common_appbar.dart';
import 'package:webview/widgets/common_button.dart';
import 'package:webview/widgets/common_drawer.dart';
import 'package:webview/widgets/common_textfield.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
    final db = DatabaseHelper();
  List<Map<String, dynamic>> notes = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
 
   @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    notes = await db.getSetting();
    setState(() {});
  }

  Future<String?> verifyEntry() async {
    if (nameController.text.trim() == "") {
      return "Fill Name Field";
    }
    if (valueController.text.trim() == "") {
      return "Fill Value Field";
    }
    // if (iconController.text.trim() == "") {
    //   return "Fill Icon Field";
    // }
    return null;
  }

  Future<void> addData() async {
    String? errorText = await verifyEntry();

    if (errorText == null) {
      int id = await db.insertSetting(
        nameController.text,
        valueController.text
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
     valueController.clear();
    // iconController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(title: "Settings"),
      drawer: CommonDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
             CommonTextfield(
                title: "Name",
                hintText: "Enter Name",
                controller: nameController,
              ),
                CommonTextfield(
                title: "Value",
                hintText: "Enter Value",
                controller: valueController,
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
               SizedBox(height: 20),
            Expanded(
            child: notes.isEmpty
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
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return GestureDetector(
                        onTap: (){
                       //  Navigator.push(context,  MaterialPageRoute(builder: (context) => webview(url:note['url'])));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(6),
                            ),
                           
                            child: ListTile(
                              title: Text(note['name'],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(note['value'],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await db.deleteSetting(note['id']);
                                  loadData();
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
      ),
    );
  }
}