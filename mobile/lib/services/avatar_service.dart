import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/account.dart';

Future<http.Response?> putCameraImageAvatar(UploadAvatarBody data) async {
  const url = "$API_URL/account/avatar/upload";
  http.Response? response;
  try {
    response = await http.put(Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode(data.toJson()));
  } catch (error) {
    log(error.toString());
  }
  return response;
}

Future<http.Response?> putPredefinedAvatar(UploadAvatarBody data) async {
  const url = "$API_URL/account/avatar/choose";
  http.Response? response;
  try {
    response = await http.put(Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode(data.toJson()));
  } catch (error) {
    log(error.toString());
  }
  return response;
}

// Convert image data to Base64 string
String imageToBase64(Uint8List imageData) {
  return base64Encode(imageData);
}

// Convert Base64 string to buffer image
Uint8List base64ToBuffer(String base64Image) {
  return base64Decode(base64Image);
}

// Convert Base64 string to image avatar
ImageProvider base64ToImage(String base64Image) {
  Uint8List bufferImage = base64ToBuffer(base64Image);
  return MemoryImage(bufferImage);
}

String getDefaultAvatarUrl(String id) {
  return '$BASE_URL/avatar/default$id.png';
}
