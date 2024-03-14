import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/models.dart';
import 'package:mobile/services/avatar_service.dart';
import 'package:mobile/services/register_service.dart';

enum AvatarType { predefined, camera }

class RegisterProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isBack = false;

  Future<void> postCredentialsData(SignUpCredentialsBody body) async {
    isLoading = true;
    notifyListeners();
    http.Response response = (await registerCredentials(body))!;
    if (response.statusCode == 200) {
      isBack = true;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> putAvatarData(
      UploadAvatarBody body, AvatarType avatarType) async {
    isLoading = true;
    isBack = false;
    notifyListeners();

    switch (avatarType) {
      case AvatarType.predefined:
        http.Response response = (await putPredefinedAvatar(body))!;
        if (response.statusCode == 200) {
          isBack = true;
        }
      case AvatarType.camera:
        http.Response response = (await putCameraImageAvatar(body))!;
        if (response.statusCode == 200) {
          isBack = true;
        }
    }
    isLoading = false;
    notifyListeners();
  }
}
