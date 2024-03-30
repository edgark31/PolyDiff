import 'package:flutter/material.dart';

class CustomTextTheme {
  CustomTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 140,
      fontWeight: FontWeight.bold,
      color: Color(0xFFE8A430),
      letterSpacing: 0.0,
    ),
  );
  static TextTheme darkTextTheme = TextTheme();
}
