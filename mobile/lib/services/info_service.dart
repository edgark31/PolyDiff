import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/models.dart';

class InfoService extends ChangeNotifier {
  static late Credentials credentials;
  static String _username = 'temp_name';
  static String _id = 'temp_id';
  static String _avatar =
      'temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar';
  static String _email = 'temp_email';
  static String _theme = 'light';
  static String _language = 'fr';
  static String _onErrorSound = '1';
  static String _onCorrectSound = '1';

  String get username => _username;
  String get id => _id;
  String get avatar => _avatar;
  String get email => _email;
  String get language => _language;
  String get theme => _theme;
  String get onErrorSound => _onErrorSound;
  String get onCorrectSound => _onCorrectSound;

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

  void setOnErrorSound(String newOnErrorSound) {
    print(
        'Changing onErrorSoundId from $_onErrorSound to $newOnErrorSound for $username ($_id)');
    _onErrorSound = newOnErrorSound;
    notifyListeners();
  }

  void setOnCorrectSound(String newOnCorrectSound) {
    print(
        'Changing onCorrectSoundId from $_onCorrectSound to $newOnCorrectSound for $username ($_id)');
    _onCorrectSound = newOnCorrectSound;
  }

  void setAvatar(String newAvatar) {
    String shortOldAvatar = _avatar.substring(0, 100);
    String shortNewAvatar = newAvatar.substring(0, 100);
    print(
        'Changing avatar from $shortOldAvatar to  $shortNewAvatar for $username ($_id)');
    _avatar = newAvatar;
    notifyListeners();
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

  // TODO
  void setAccountInfo(Profile fetchedProfile) {}

  void setInfosOnConnection(String serverConnectionResponse) {
    final result = jsonDecode(serverConnectionResponse) as Map<String, dynamic>;

    // print('id: ${result['id']}');
    setId(result['id']);

    // print('credentials: ${result['credentials']}');
    final credentials = Credentials.fromJson(result['credentials']);
    // print('email: ${credentials.email}');
    // print('username: ${credentials.username}');
    setCredentials(credentials);

    setAvatar(result['profile']['avatar']);
    setTheme(result['profile']['mobileTheme']);
    setLanguage(result['profile']['language']);
    setOnCorrectSound(result['profile']['onCorrectSoundId']);
    setOnErrorSound(result['profile']['onErrorSoundId']);
  }
}
