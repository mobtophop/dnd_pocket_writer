import 'package:flutter/material.dart';
import 'package:dnd_pocket_writer/misc/app_colors.dart';

class PageBase extends StatelessWidget {
  const PageBase({
    super.key,
    required this.child,
    this.title,
    this.drawer,
    this.onDrawerChanged,
  });

  final Widget child;
  final Drawer? drawer;
  final Widget? title;
  final Function(bool)? onDrawerChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: onDrawerChanged,
      appBar: AppBar(
        title: title,
        backgroundColor: AppColors.main,
      ),
      body: child,
      drawer: drawer,
    );
  }
}
