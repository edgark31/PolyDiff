import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/avatar_service.dart';
import 'package:mobile/services/register_service.dart';

enum AvatarType { predefined, camera }

class RegisterProvider extends ChangeNotifier {
  final AvatarProvider _avatarProvider = Get.find();
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
        print('putAvatarData: $body inside cas predefined');
        try {
          print('before await inside cas predefined');
          http.Response response = (await putPredefinedAvatar(body))!;
          print('after inside cas predefined');
          if (response.statusCode == 200) {
            String body = response.body;
            isBack = true;
            isLoading = false;
            print("Successfully updating predefined avatar $body");
            _avatarProvider.setAccountAvatarUrl();

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
