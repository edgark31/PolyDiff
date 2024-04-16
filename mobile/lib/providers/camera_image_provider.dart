import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class CameraImageProvider extends ChangeNotifier {
  Future<String?> pickImageFromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage == null) return null;

      final Uint8List? resizedImage =
          await FlutterImageCompress.compressWithFile(
        pickedImage.path,
        minWidth: 128,
        minHeight: 128,
        quality: 100,
      );

      if (resizedImage != null) {
        // Convert to base64
        final String base64Image = base64Encode(resizedImage);
        notifyListeners();
        return base64Image;
      }
    } catch (e) {
      print('Failed to pick image: $e');
      return null;
    }
    return null;
  }
}
