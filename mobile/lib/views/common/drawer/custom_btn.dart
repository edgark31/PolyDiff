import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/views/common/drawer/app_style.dart';
import 'package:mobile/views/common/drawer/reusable_text.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.color,
    this.onTap,
  });

  final String text;
  final Color? color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height * 0.065,
          child: Center(
            child: ReusableText(
                text: text,
                style: appstyle(
                    16, color ?? Color(kLightGreen.value), FontWeight.w600)),
          ),
        ));
  }
}
