import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/models/credentials.dart';

class FormService {
  final baseUrl = 'http://localhost:3000';

  FormService(String baseUrl);

  Future<void> register(Credentials credentials) async {
    final url = '$baseUrl/api/account/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credentials.toJson()),
      );

      if (response.statusCode == 200) {
        print('Registration successful');
      } else if (response.statusCode == 409) {
        print('Registration failed: Conflict');
      } else {
        print('Registration failed with status code ${response.statusCode}');
      }
    } catch (error) {
      print('Error during registration: $error');
    }
  }
}
