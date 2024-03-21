import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/models.dart';

class InfoService extends ChangeNotifier {
  static late Credentials credentials;
  static String _username = 'temp_name';
  static String _id = 'temp_id';
  static String _email = 'temp_email';
  static String _theme = 'light';
  static String _language = 'fr';
  static Sound _onErrorSound = DEFAULT_ON_ERROR_SOUND;
  static Sound _onCorrectSound = DEFAULT_ON_CORRECT_SOUND;

  String get username => _username;
  String get id => _id;

  String get email => _email;
  String get language => _language;
  String get theme => _theme;
  Sound get onErrorSound => _onErrorSound;
  Sound get onCorrectSound => _onCorrectSound;

  void setId(String newId) {
    // print('Changing id from $_id to $newId');
    _id = newId;
    notifyListeners();
  }

  void setUsername(String newName) {
    print('Changing name from $_username to $newName for ($_id)');
    _username = newName;
    notifyListeners();
  }

  void setEmail(String? newEmail) {
    if (newEmail != null) {
      // print('Changing email from $_email to $newEmail for $username ($_id)');
      _email = newEmail;
      notifyListeners();
    }
  }

  void setTheme(String newTheme) {
    print('Changing theme from $_theme to $newTheme for $username ($_id)');
    _theme = newTheme;
    notifyListeners();
  }

  void setOnErrorSound(Sound newOnErrorSound) {
    print(
        'Changing onErrorSoundId from $_onErrorSound to $newOnErrorSound for $username ($_id)');
    _onErrorSound = newOnErrorSound;
    notifyListeners();
  }

  void setOnCorrectSound(Sound newOnCorrectSound) {
    print(
        'Changing onCorrectSoundId from $_onCorrectSound to $newOnCorrectSound for $username ($_id)');
    _onCorrectSound = newOnCorrectSound;
  }

  void setLanguage(String newLanguage) {
    print(
        'Changing language from $_language to $newLanguage for $username ($_id)');
    _language = newLanguage;
    notifyListeners();
  }

  void setCredentials(Credentials credentialsReceived) {
    credentials = credentialsReceived;
    setUsername(credentials.username);
    setEmail(credentials.email);
  }

  void setInfosOnConnection(String serverConnectionResponse) {
    final result = jsonDecode(serverConnectionResponse) as Map<String, dynamic>;

    // print('id: ${result['id']}');
    setId(result['id']);

    // print('credentials: ${result['credentials']}');
    final credentials = Credentials.fromJson(result['credentials']);
    final onErrorSound = Sound.fromJson(result['profile']['onErrorSound']);
    final onCorrectSound = Sound.fromJson(result['profile']['onCorrectSound']);

    setCredentials(credentials);

    setTheme(result['profile']['mobileTheme']);
    setLanguage(result['profile']['language']);
    setOnCorrectSound(onCorrectSound);
    setOnErrorSound(onErrorSound);
  }
}
