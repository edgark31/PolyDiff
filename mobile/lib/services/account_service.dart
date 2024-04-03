import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/account.dart';

// Providers are for state management
class AccountService {
  final String baseUrl = API_URL;

  // Password
  Future<String?> updatePassword(String username, String newPassword) async {
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
      if (response.statusCode == 200) {
        print('Modified successfully ');
        return null;
      }
    } catch (error) {
      return 'Error: $error';
    }
    return null;
  }

  // Password
  Future<String?> updateUsername(String oldUsername, String newUsername) async {
    try {
      print(
          "*** Server Updating username from $oldUsername to $newUsername, path : $baseUrl/account/pseudo ***");
      final response = await http.put(
        Uri.parse('$baseUrl/account/username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'oldUsername': oldUsername,
          'newUsername': newUsername,
        }),
      );
      if (response.statusCode == 200) {
        print("$oldUsername updated to $newUsername ");
        return null;
      }
    } catch (error) {
      print("Failed to update username : $error");
      return 'Error: $error';
    }
    return null;
  }

  // Theme
  Future<String?> updateTheme(String username, String newTheme) async {
    final String themeToLowerCase = newTheme.toLowerCase();
    try {
      print('Entering updateTheme try');
      final response = await http.put(
        Uri.parse('$baseUrl/account/mobile/theme'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'newTheme': themeToLowerCase,
        }),
      );
      if (response.statusCode == 200) {
        print("Theme updated to $themeToLowerCase ");
        return null;
      } else {
        print("Failed to update theme");
        print(response.body);
        print(response.statusCode);
      }
    } catch (error) {
      print("Error updating theme preference: $error");
      return 'Error: $error';
    }
    return null;
  }

  // Language
  Future<String?> updateLanguage(String username, String newLanguage) async {
    String newLanguageFormatted;
    switch (newLanguage) {
      case 'Français':
      case 'French':
        newLanguageFormatted = 'fr';

      case 'Anglais':
      case 'English':
        newLanguageFormatted = 'en';

      default:
        newLanguageFormatted = 'fr';
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/account/language'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'newLanguage': newLanguageFormatted,
        }),
      );
      if (response.statusCode == 200) {
        print("Language updated to $newLanguageFormatted ");
        return null;
      }
    } catch (error) {
      print("Error updating language preference: $error");
      return 'Error: $error';
    }
    return null;
  }

  Future<String?> updateCorrectSound(String username, Sound newSound) async {
    final url = Uri.parse("$baseUrl/account/sound/correct");
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "newSound": newSound}),
      );
      if (response.statusCode == 200) {
        print("Correct sound updated to $newSound");
        return null;
      }
    } catch (error) {
      print("Error updating correct sound preference: $error");
      return 'Error: $error';
    }
    return null;
  }

  Future<String?> updateErrorSound(String username, Sound newSound) async {
    final url = Uri.parse("$baseUrl/account/sound/error");
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "newSound": newSound}),
      );
      if (response.statusCode == 200) {
        print("Failed to update sound preference");
        return null;
      }
    } catch (error) {
      // Handle error
      print("Error updating sound preference: $error");
      return 'Error: $error';
    }
    return null;
  }
}
