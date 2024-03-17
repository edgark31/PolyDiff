import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/models.dart';
import 'package:mobile/services/avatar_service.dart';
import 'package:mobile/services/register_service.dart';

enum AvatarType { predefined, camera }

class RegisterProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isBack = false;

  Future<String?> postCredentialsData(SignUpCredentialsBody body) async {
    isLoading = true;
    notifyListeners();
    try {
      http.Response response = (await registerCredentials(body))!;
      if (response.statusCode == 200) {
        isBack = true;
        print('Successfully posting CredentialsData in register provider');
      }
    } catch (error) {
      isLoading = false;
      notifyListeners();
      return 'Error: $error';
    }
    isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> putAvatarData(
      UploadAvatarBody body, AvatarType avatarType) async {
    isLoading = true;
    isBack = false;
    notifyListeners();

    switch (avatarType) {
      case AvatarType.predefined:
        try {
          http.Response response = (await putPredefinedAvatar(body))!;
          if (response.statusCode == 200) {
            String body = response.body;
            isBack = true;
            isLoading = false;
            print("Successfully updating predefined avatar $body");

            notifyListeners();
            return null;
          }
        } catch (e) {
          isLoading = false;
          notifyListeners();
          return 'Error updating predefined avatar ';
        }
      case AvatarType.camera:
        try {
          http.Response response = (await putCameraImageAvatar(body))!;
          if (response.statusCode == 200) {
            isBack = true;
          }
        } catch (error) {
          isLoading = false;
          notifyListeners();
          return 'Error: $error';
        }
    }
    isLoading = false;
    notifyListeners();
    return null;
  }
}
