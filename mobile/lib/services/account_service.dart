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
        return "Modified profile successfully";
      }
    } catch (error) {
      return 'Error: $error';
    }
    return null;
  }

  // Password
  Future<String?> updateUsername(String oldUsername, String newUsername) async {
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
        print("Langugae updated to $newLanguageFormatted ");
        return null;
      }
    } catch (error) {
      print("Error updating language preference: $error");
      return 'Error: $error';
    }
    return null;
  }

  Future<String?> updateCorrectSound(String username, String newSoundId) async {
    final url = Uri.parse("$baseUrl/account/sound/correct");
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "soundId": newSoundId}),
      );
      if (response.statusCode == 200) {
        print("Correct sound updated to $newSoundId ");
        return null;
      }
    } catch (error) {
      print("Error updating correct sound preference: $error");
      return 'Error: $error';
    }
    return null;
  }

  Future<String?> updateErrorSound(String username, String newSoundId) async {
    final url = Uri.parse("$baseUrl/account/sound/error");
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "soundId": newSoundId}),
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
