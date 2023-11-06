import 'package:flutter/material.dart';
import 'package:dnd_pocket_writer/misc/app_colors.dart';

class PageBase extends StatelessWidget {
  const PageBase({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.main,
      ),
      body: child,
    );
  }
}