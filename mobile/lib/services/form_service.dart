import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/info_service.dart';

class FormService {
  final baseUrl = API_URL;
  final InfoService infoService = Get.find();

  FormService();

  Future<String?> register(SignUpCredentialsBody data) async {
    final url = '$baseUrl/account/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('credentials sent');
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
        String info = response.body;
        infoService.setInfosOnConnection(info);
        print('SET INFO ON CONNECTION : $info');
        return null;
      } else {
        final errorMessage = response.body;
        return errorMessage;
      }
    } catch (error) {
      return 'Error: $error';
    }
  }

  Future<String?> sendMail(String email) async {
    final String url = '$baseUrl/account/mail';
    try {
      final requestBody = {'email': email};
      final response = await http.put(
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
