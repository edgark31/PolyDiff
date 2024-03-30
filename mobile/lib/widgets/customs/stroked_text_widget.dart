import 'package:flutter/material.dart';

class StrokedTextWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final double strokeWidth;
  final Color strokeColor;

  const StrokedTextWidget({
    super.key,
    required this.text,
    required this.textStyle,
    this.strokeWidth = 2.0,
    this.strokeColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          style: textStyle,
        ),
      ],
    );
  }
}
