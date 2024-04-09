import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/info_service.dart';

class FormService extends ChangeNotifier {
  final baseUrl = API_URL;
  final InfoService infoService = Get.find();
  int passwordCode = 123456;
  String usernameToChangePassword = '';

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
        Map<String, dynamic> body = jsonDecode(response.body);
        print(body['credentials']['recuperatePasswordCode']);
        passwordCode = int.parse(body['credentials']['recuperatePasswordCode']);
        print('passwordCode is now : $passwordCode');
        usernameToChangePassword = body['credentials']['username'];
        print('usernameToChangePassword is now : $usernameToChangePassword');
        return null;
      } else {
        final errorMessage = response.body;
        return errorMessage;
      }
    } catch (error) {
      return 'Error: $error';
    }
  }

  bool checkCode(int code) {
    return code == passwordCode;
  }

  Future<String?> changePassword(String newPassword) async {
    final String url = '$baseUrl/account/password';
    try {
      final requestBody = {
        'username': usernameToChangePassword,
        'newPassword': newPassword,
      };
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('changePassword returned 200');
        return null;
      } else {
        print('changePassword DID NOT return 200');
        final errorMessage = response.body;
        return errorMessage;
      }
    } catch (error) {
      print('error was caught by changePassword : $error');
      return 'Error: $error';
    }
  }
}
