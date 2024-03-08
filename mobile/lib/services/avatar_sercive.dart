import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';

class AvatarService {
  AvatarService(String baseUrl);

  // If avatar is from camera
  Future<String?> uploadAvatar(String username, String base64Avatar) async {
    const String url = '$BASE_URL/avatar/upload';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'avatar': base64Avatar,
        }),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return response.body;
      }
    } catch (error) {
      return 'Error: $error';
    }
  }

  // DEFAULT
  Future<String?> chooseAvatar(String username, String id) async {
    const String url = '$BASE_URL/avatar/choose';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'id': id,
        }),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return response.body;
      }
    } catch (error) {
      return 'Error: $error';
    }
  }
}
