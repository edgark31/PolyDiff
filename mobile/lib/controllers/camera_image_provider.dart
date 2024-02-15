import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CameraImageUploader extends ChangeNotifier {
  File? image;

  void pickImageFromCamera(Function(File?) setImage) async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage == null) return;

      final imageTemp = File(pickedImage.path);
      image = imageTemp;
      setImage(image);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }
}
