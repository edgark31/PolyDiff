import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/constants/config.dart';
import 'package:mobile/models/login_model.dart';
import 'package:mobile/models/login_res_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static var client = http.Client();

  static Future<bool> login(LoginModel model) async {
    Map<String, String> requestHeaders = {'Content-type': 'application/json'};

    var url = Uri.https(Config.apiUrl, Config.loginUrl);
    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model),
    );

    if (response.statusCode == 200) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = loginResponseModelFromJson(response.body).userToken;
      String userId = loginResponseModelFromJson(response.body).id;
      String profile = loginResponseModelFromJson(response.body).profile;

      await prefs.setString('token', token);
      await prefs.setString('userId', userId);
      await prefs.setString('profile', profile);

      await prefs.setBool('loggedIn', true);

      return true;
    } else {
      return false;
    }
  }
}
