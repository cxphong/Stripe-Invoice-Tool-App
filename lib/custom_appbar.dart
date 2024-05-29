import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Text title;
  final List<Widget>? actions;
  final Color? backgroundColor;

  CustomAppBar({
    required this.title,
    this.actions,
    this.backgroundColor, // Make background color required
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80.0); // Set the custom height here
}
