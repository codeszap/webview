import 'package:flutter/material.dart';

class CommonAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions; // 👈 optional actions added

  const CommonAppbar({super.key, required this.title, this.actions});

  @override
  State<CommonAppbar> createState() => _CommonAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CommonAppbarState extends State<CommonAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      foregroundColor: Colors.white,
      actions: widget.actions, // 👈 use if available
    );
  }
}
