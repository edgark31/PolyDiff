import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';

enum AvatarType { predefined, camera }

class AvatarServiceException implements Exception {
  final String message;
  AvatarServiceException(this.message);

  @override
  String toString() => message;
}

class AvatarService {
  AvatarService();

  // Convert image data to Base64 string
  String imageToBase64(Uint8List imageData) {
    return base64Encode(imageData);
  }

  // Upload avatar from camera
  Future<String?> uploadCameraImage(
      String username, Uint8List imageData) async {
    String base64Avatar = imageToBase64(imageData);
    return uploadAvatar(username, base64Avatar);
  }

  // If avatar is from camera or selected file
  Future<String?> uploadAvatar(String username, String base64Avatar) async {
    const String url = '$API_URL/avatar/upload';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'avatar': base64Avatar}),
      );

      if (response.statusCode == 200) {
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
    const String url = '$API_URL/avatar/choose';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'id': id}),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return response.body;
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
