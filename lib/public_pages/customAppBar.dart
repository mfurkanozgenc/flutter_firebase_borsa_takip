import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onBackPressed;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar(
      {Key? key,
      required this.title,
      this.backgroundColor = Colors.white,
      this.iconColor = Colors.black,
      required this.onBackPressed,
      this.actions,
      this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(color: iconColor),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
