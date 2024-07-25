import 'package:flutter/material.dart';
import 'package:project/constants/colors_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color titleColor;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.titleColor = ColorConstants.generalColor,
      this.backgroundColor = Colors.white,
      this.actions,
      this.leading});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
