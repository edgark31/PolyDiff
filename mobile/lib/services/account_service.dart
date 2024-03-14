import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';

enum Sound {
  onError,
  onFoundDifference,
}

// Providers are for state management
class AccountService {
  final String baseUrl = API_URL;

  String _responseFeedBack(http.Response response) {
    if (response.statusCode == 200) {
      return "Modified profile successfully";
    }
    return 'Error ${response.statusCode}: ${response.body}';
  }

  String _catchErrorMessage(Object error) {
    return 'Error : $error';
  }

  // Password
  Future<String> changePassword(String username, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/account/password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'newPassword': newPassword,
        }),
      );

      return _responseFeedBack(response);
    } catch (error) {
      return _catchErrorMessage(error);
    }
  }

  // Password
  Future<String> changePseudo(String oldUsername, String newUsername) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/account/pseudo'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'oldUsername': oldUsername,
          'newUsername': newUsername,
        }),
      );

      return _responseFeedBack(response);
    } catch (error) {
      return _catchErrorMessage(error);
    }
  }

  // Password
  Future<String> changeEmail(String username, String newEmail) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/account/mail'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'newEmail': newEmail,
        }),
      );

      return _responseFeedBack(response);
    } catch (error) {
      return _catchErrorMessage(error);
    }
  }

  // Theme
  Future<String?> modifyTheme(String username, String newTheme) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/account/theme'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'newTheme': newTheme,
        }),
      );
      _responseFeedBack(response);
    } catch (error) {
      _catchErrorMessage(error);
    }
  }

  // Language
  Future<String?> modifyLanguage(String username, String newLanguage) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/account/language'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'newLanguage': newLanguage, // TODO : server newLanguage
        }),
      );

      _responseFeedBack(response);
    } catch (error) {
      _catchErrorMessage(error);
    }
  }

  // TODO: Check with server routes
  Future<String?> modifySound(
      String username, String newErrorSoundId, Sound soundType) async {
    String endpoint = (soundType == Sound.onError) ? 'error' : 'difference';

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/account/sound/$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'newErrorSoundId': newErrorSoundId,
        }),
      );

      _responseFeedBack(response);
    } catch (error) {
      _catchErrorMessage(error);
    }
  }
}
