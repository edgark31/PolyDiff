import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';

const url = "$API_URL/account/register";

Future<http.Response?> registerCredentials(SignUpCredentialsBody data) async {
  http.Response? response;
  try {
    response = await http.post(Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode(data.toJson()));
  } catch (error) {
    log(error.toString());
  }
  return response;
}
