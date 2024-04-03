import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/utils/theme_utils.dart';

class ThemeProvider extends ChangeNotifier {
  final InfoService _infoService = Get.find();

  // ThemeMode _themeMode = ThemeMode.system;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeProvider() {
    _themeMode =
        _infoService.theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }
  ThemeData _lightTheme = ThemeClass.lightTheme;
  ThemeData _darkTheme = ThemeClass.darkTheme;

  ThemeMode get themeMode => _themeMode;

  // Determine the current theme based on the theme mode
  ThemeData get theme =>
      _themeMode == ThemeMode.dark ? _darkTheme : _lightTheme;
  // ThemeData get theme =>
  //     _themeMode == ThemeMode.dark ? _darkTheme : _lightTheme;

  bool get isDarkMode {
    print('_themeMode : $_themeMode');
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool isDarkTheme) {
    print('_themeMode : $_themeMode');
    _themeMode = isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
