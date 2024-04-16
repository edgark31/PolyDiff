import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:mobile/models/canvas_model.dart';

class ImageConverterService {
  // Convert base64 string to Uint8List
  static Uint8List uint8listFromBase64String(String base64String) {
    int positionComma = base64String.indexOf(',');
    return base64Decode(base64String.substring(positionComma + 1));
  }

  // Convert base64 string to Image
  static Future<ui.Image> imageFromBase64String(String base64String) async {
    Uint8List data = uint8listFromBase64String(base64String);
    ui.Codec codec = await ui.instantiateImageCodec(data);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  // Create CanvasModel from two base64 images
  static Future<CanvasModel> fromImagesBase64(
      String originalImageBase64, String modifiedImageBase64) async {
    final ui.Image originalImage =
        await imageFromBase64String(originalImageBase64);
    final ui.Image modifiedImage =
        await imageFromBase64String(modifiedImageBase64);

    return CanvasModel(
      original: originalImage,
      modified: modifiedImage,
    );
  }
}
