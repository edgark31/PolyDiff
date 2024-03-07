import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:mobile/models/canvas_model.dart';

class ImageConverterService {
  ImageConverterService();
  Future<CanvasModel> fromImagePath(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    //temporaire
    final ui.Image modifiedImage = frameInfo.image;

    return CanvasModel(
      original: originalImage,
      modified: modifiedImage,
    );
  }
}
