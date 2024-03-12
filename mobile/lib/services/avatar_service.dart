import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/avatar_provider.dart';

enum AvatarType { predefined, camera }

class AvatarServiceException implements Exception {
  final String message;
  AvatarServiceException(this.message);

  @override
  String toString() => message;
}

class AvatarService with ChangeNotifier {
  // Convert image data to Base64 string
  String imageToBase64(Uint8List imageData) {
    return base64Encode(imageData);
  }

  // Convert Base64 string to buffer image
  Uint8List base64ToBuffer(String base64Image) {
    return base64Decode(base64Image);
  }

  // Convert Base64 string to image avatar
  ImageProvider base64ToImage(String base64Image) {
    Uint8List bufferImage = base64ToBuffer(base64Image);
    return MemoryImage(bufferImage);
  }

  // Upload avatar from camera
  Future<String?> uploadCameraImage(
      String username, String base64Avatar) async {
    return uploadAvatar(username, base64Avatar);
  }

  String getDefaultAvatarUrl(String id) {
    return '$BASE_URL/avatar/default$id.png';
  }

  // If avatar is from camera or selected file
  Future<String?> uploadAvatar(String username, String base64Avatar) async {
    const String url = '$API_URL/account/avatar/upload';
    print("URL : $url");

    try {
      print("********** \n USERNAME : $username     BASE64:  $base64Avatar");
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'avatar': base64Avatar}),
      );

      if (response.statusCode == 200) {
        print("setting account");
        AvatarProvider.instance.setAccountAvatarUrl(username);
        return null;
      } else {
        return response.body;
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // If avatar is chosen from predefined avatar
  Future<String?> chooseAvatar(String username, String id) async {
    print("id: $id");
    print("username: $username");
    const String url = '$API_URL/account/avatar/choose';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'id': id}),
      );

      if (response.statusCode == 200) {
        print('no');
        AvatarProvider.instance.setAccountAvatarUrl(username);
        return null;
      } else {
        return response.body;
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
