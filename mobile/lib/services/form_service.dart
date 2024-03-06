import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/models/models.dart';

class FormService {
  final String baseUrl = 'http://localhost:3000/api';

  FormService(String baseUrl);

  Future<String?> register(Credentials credentials, String base64Image) async {
    final url = '$baseUrl/account/register';

    try {
      final requestBody = {
        'creds': credentials.toJson(),
        'avatar': base64Image,
      };
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final errorMessage = response.body;
        return errorMessage;
      }
    } catch (error) {
      return 'Error: $error';
    }
  }

  Future<String?> connect(Credentials credentials) async {
    final String url = '$baseUrl/account/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credentials.toJson()),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final errorMessage = response.body;
        return errorMessage;
      }
    } catch (error) {
      return 'Error: $error';
    }
  }
}
