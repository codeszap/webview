import 'package:flutter/material.dart';

class CommonTextfield extends StatefulWidget {
   CommonTextfield({
    super.key, 
   this.title="",
   this.hintText="", 
   required this.controller,
   });

 String? title;
 String? hintText;
 TextEditingController controller;

  @override
  State<CommonTextfield> createState() => _CommonTextfieldState();
}

class _CommonTextfieldState extends State<CommonTextfield> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title!),
          SizedBox(height: 8,),
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hintText!,
                  border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}