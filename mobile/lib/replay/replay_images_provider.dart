import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageState {
  int? index;
  Image? image;

  ImageState({this.index, this.image});
}

class ReplayImagesProvider extends ChangeNotifier {
  Map<int, String> _eventIndexToBase64 = {};
  ImageState _currentImage = ImageState();

  Map<int, String> get eventIndexToBase64 => _eventIndexToBase64;
  ImageState get currentCanvasStateImage => _currentImage;

  void setCanvasStatesImage(Map<int, String> canvasStates) {
    _eventIndexToBase64 = canvasStates;
    notifyListeners();
  }

  void setCurrentImageState(String base64String, int index) {
    Image currentImage = _convertFromBase64(base64String);
    _currentImage = ImageState(index: index, image: currentImage);
    notifyListeners();
  }

  // Provides the current canvas image based on the index
  void setCurrentCanvasImage(int currentIndex) {
    if (_eventIndexToBase64.containsKey(currentIndex)) {
      final String base64String = _eventIndexToBase64[currentIndex]!;

      setCurrentImageState(base64String, currentIndex);
      print("current image index: $currentIndex with base64: $base64String");
      notifyListeners();
    }
  }

  Image getCurrentCanvasImage() {
    return _currentImage.image!;
  }

  Image _convertFromBase64(String base64String) {
    final Uint8List bytes = base64Decode(base64String);
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
    );
  }
}
