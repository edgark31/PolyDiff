import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/services/image_converter_service.dart';

// Pre cache the image to be displayed
Future<void> preCacheImageFromBase64(
    BuildContext context, String base64) async {
  try {
    final Uint8List decodedBytes =
        ImageConverterService().uint8listFromBase64String(base64);
    final MemoryImage image = MemoryImage(decodedBytes);
    await precacheImage(image, context);
  } catch (e) {
    debugPrint("Error preloading image: $e");
  }
}

Image imageFromBase64(String base64String) {
  final Uint8List bytes = base64Decode(base64String);
  return Image.memory(
    bytes,
    fit: BoxFit.cover,
  );
}
