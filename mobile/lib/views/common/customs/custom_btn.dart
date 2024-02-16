import 'package:flutter/material.dart';
import 'package:mobile/views/common/customs/app_style.dart';
import 'package:mobile/views/common/customs/reusable_text.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.width,
    this.height,
    required this.text,
    this.onTap,
    required this.color,
    this.color2,
  });

  final double? width;
  final double? height;
  final String text;
  final void Function()? onTap;
  final Color color;
  final Color? color2;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color2,
            border: Border.all(width: 4, color: color),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: ReusableText(
                text: text, style: appstyle(10, color, FontWeight.w600)),
          ),
        ));
  }
}
