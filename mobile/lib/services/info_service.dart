import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/models.dart';

class InfoService extends ChangeNotifier {
  static late Credentials credentials;
  static String _username = 'temp_name'; // TODO : fix default avatar issue
  static String _id = 'temp_id';
  static String _avatar =
      'temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar';
  static String _email = 'temp_email';
  static String _language = 'fr';
  static String _soundOnError = 'sound/ErrorSoundEffect.mp3';
  static String _soundOnDifference = 'sound/WinSoundEffect.mp3';

  String get username => _username;
  String get id => _id;
  String get avatar => _avatar;
  String get email => _email;
  String get language => _language;
  String get soundOnError => _soundOnError;
  String get soundOnDifference => _soundOnDifference;

  void setId(String newId) {
    print('Changing id from $_id to $newId');
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
      print('Changing email from $_email to $newEmail for $username ($_id)');
      _email = newEmail;
      notifyListeners();
    }
  }

  void setSoundOnError(String newSoundOnError) {
    print(
        'Changing onErrorSound from $_soundOnError to $newSoundOnError for $username ($_id)');
    _email = newSoundOnError;
    notifyListeners();
  }

  void setSoundOnDifference(String newSoundOnDifference) {
    print(
        'Changing email from $_soundOnDifference to $newSoundOnDifference for $username ($_id)');
    _email = newSoundOnDifference;
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
        'Changing language from $_email to $newLanguage for $username ($_id)');
    _email = newLanguage;
    notifyListeners();
  }

  void setCredentials(Credentials credentialsReceived) {
    credentials = credentialsReceived;
    setUsername(credentials.username);
    setEmail(credentials.email);
  }

  void setInfosOnConnection(String serverConnectionResponse) {
    final result = jsonDecode(serverConnectionResponse) as Map<String, dynamic>;

    print('id: ${result['id']}');
    setId(result['id']);

    print('credentials: ${result['credentials']}');
    final credentials = Credentials.fromJson(result['credentials']);
    print('email: ${credentials.email}');
    print('username: ${credentials.username}');
    setCredentials(credentials);

    setAvatar(
        result['profile']['avatar']); // TODO : Add the rest of the profile
  }
}
