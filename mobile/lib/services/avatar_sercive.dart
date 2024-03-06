import 'dart:convert';

import 'package:http/http.dart' as http;

class AvatarService {
  final baseUrl = 'http://localhost:3000/api';

  AvatarService(String baseUrl);

  Future<String?> uploadAvatar(String username, String base64Avatar) async {
    final String url = '$baseUrl/avatar/upload';

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

  Future<String?> chooseAvatar(String username, String id) async {
    final String url = '$baseUrl/avatar/choose';
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
