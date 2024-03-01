import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/models/credentials.dart';

class FormService {
  final baseUrl = 'http://localhost:3000/api';

  FormService(String baseUrl);

  Future<String?> register(Credentials credentials, String id) async {
    final url = '$baseUrl/account/register';

    try {
      final requestBody = {
        'creds': credentials.toJson(),
        'id': id,
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
}
