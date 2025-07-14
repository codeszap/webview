import 'package:flutter/material.dart';

class CommonButton extends StatefulWidget {
   CommonButton({super.key,
     this.title ="", 
     this.backgroundColor = Colors.green, 
     this.textcolor = Colors.white,
     this.tap,
    });

String? title;
Color? backgroundColor;
Color? textcolor;
Function()? tap;

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  widget.tap,
      child: Container(
        width:double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),

        child: Padding(
          padding:  EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              widget.title!,
              style: TextStyle(color:  widget.textcolor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
