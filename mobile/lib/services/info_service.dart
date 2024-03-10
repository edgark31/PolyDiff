import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/models.dart';

class InfoService extends ChangeNotifier {
  static late Credentials credentials;
  static String _name = 'temp_name'; // TODO : fix default avatar issue
  static String _id = 'temp_id';
  static String _avatar =
      'temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar_temp_avatar';
  static String _email = 'temp_email';

  String get username => _name;
  String get id => _id;
  String get avatar => _avatar;
  String get email => _email;

  void setId(String newId) {
    print('Changing name from $_id to $newId for $_id');
    _id = newId;
    notifyListeners();
  }

  void setName(String newName) {
    // print('Changing name from $_name to $newName for $_id');
    _name = newName;
    notifyListeners();
  }

  void setEmail(String? newEmail) {
    if (newEmail != null) {
      // print('Changing email from $_email to $newEmail for $_id');
      _email = newEmail;
      notifyListeners();
    }
  }

  void setAvatar(String newAvatar) {
    String shortOldAvatar = _avatar.substring(0, 100);
    String shortNewAvatar = newAvatar.substring(0, 100);
    // print('Changing avatar from $shortOldAvatar to  $shortNewAvatar for $_id');
    _avatar = newAvatar;
    notifyListeners();
  }

  void setCredentials(Credentials credentialsReceived) {
    credentials = credentialsReceived;
    setName(credentials.username);
    setEmail(credentials.email);
  }

  void setInfosOnConnection(String serverConnectionResponse) {
    final result = jsonDecode(serverConnectionResponse) as Map<String, dynamic>;

    // print('id: ${result['id']}');
    setId(result['id']);

    // print('credentials: ${result['credentials']}');
    final credentials = Credentials.fromJson(result['credentials']);
    // print('email: ${credentials.email}');
    // print('username: ${credentials.username}');
    setCredentials(credentials);

    setAvatar(
        result['profile']['avatar']); // TODO : Add the rest of the profile
  }
}
