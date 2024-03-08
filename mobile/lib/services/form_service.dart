import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/info_service.dart';

class FormService {
  final baseUrl = BASE_URL;
  final InfoService infoService = Get.find();

  FormService(String baseUrl);

  Future<String?> register(Credentials credentials) async {
    final url = '$baseUrl/account/register';

    try {
      final requestBody = {
        'creds': credentials.toJson(),
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
        infoService.setInfosOnConnection(response.body);
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
