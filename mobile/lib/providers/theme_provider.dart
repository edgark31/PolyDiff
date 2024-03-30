import 'package:flutter/material.dart';
import 'package:mobile/utils/theme_utils.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeData _lightTheme = ThemeClass.lightTheme;
  ThemeData _darkTheme = ThemeClass.darkTheme;

  ThemeMode get themeMode => _themeMode;

  // Determine the current theme based on the theme mode
  ThemeData get theme =>
      _themeMode == ThemeMode.dark ? _darkTheme : _lightTheme;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return false;
    } else {
      return _themeMode == ThemeMode.dark;
    }
  }

  void toggleTheme(bool isDarkTheme) {
    _themeMode = isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
