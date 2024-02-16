import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/views/common/customs/app_style.dart';
import 'package:mobile/views/common/customs/reusable_text.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    this.text,
    required this.child,
    this.actions,
  });

  final String? text;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(),
      backgroundColor: kLime,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: child,
      actions: actions,
      centerTitle: true,
      title: ReusableText(
          text: text ?? "",
          style: appstyle(16, Color(kLight.value), FontWeight.w600)),
    );
  }
}
