import 'package:flutter/material.dart';

class ThemeClass {
  // Colors
  Color kDark = Colors.black;
  Color kLight = Color(0xFFFFFFFF);

  Color kLime = Color.fromRGBO(158, 157, 36, 1);

  Color kGreen = Color(0xFF43A047);
  Color kLightGreen = Color.fromRGBO(85, 139, 47, 1);
  Color kMidGreen = Color.fromRGBO(123, 142, 5, 1);
  Color kDarkGreen = Color.fromARGB(255, 7, 93, 15);

  Color kLightOrange = Color.fromRGBO(245, 124, 0, 1);
  Color kMidOrange = Color.fromRGBO(239, 108, 0, 1);
  Color kDarkOrange = Color.fromRGBO(230, 81, 0, 1);

  Color kMidPink = Color.fromRGBO(255, 105, 180, 1);

  static ThemeData lightTheme = ThemeData(
    primaryColor: ThemeData.light().scaffoldBackgroundColor,
    colorScheme: const ColorScheme.light().copyWith(
      primary: _themeClass.kLightOrange,
      secondary: _themeClass.kMidOrange,
      onSecondary: _themeClass.kLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: ThemeData.dark().scaffoldBackgroundColor,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: _themeClass.kDarkGreen,
      secondary: _themeClass.kMidGreen,
      onSecondary: _themeClass.kLight,
    ),
  );

  // static ThemeData lightTheme = ThemeData(
  //   useMaterial3: true,
  //   fontFamily: 'troika',
  //   brightness: Brightness.light,
  //   scaffoldBackgroundColor: Colors.white,
  //   primaryColor: Colors.orangeAccent.shade400,
  //   textTheme: CustomTextTheme.lightTextTheme,
  // );

  // static ThemeData darkTheme = ThemeData(
  //   useMaterial3: true,
  //   fontFamily: 'troika',
  //   scaffoldBackgroundColor: Colors.grey.shade900,
  //   brightness: Brightness.dark,
  //   primaryColor: Colors.black,
  //   textTheme: CustomTextTheme.darkTextTheme,
  // );
}

ThemeClass _themeClass = ThemeClass();
