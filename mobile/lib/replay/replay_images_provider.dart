import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/models/canvas_model.dart';

class ImageState {
  int? eventIndex;
  Future<ui.Image> image;
  bool isMainCanvas;

  ImageState(
      {required this.eventIndex,
      required this.image,
      required this.isMainCanvas});
}

class CurrentImageState {
  int eventIndex;
  Future<CanvasModel> images;
  bool isMainCanvas;

  CurrentImageState(
      {required this.eventIndex,
      required this.images,
      required this.isMainCanvas});
}

class ReplayImagesProvider extends ChangeNotifier {
  List<ImageState> _canvasStates = [];
  late Future<CanvasModel> _currentCanvas;

  List<ImageState> get canvasStates => _canvasStates;

  Future<CanvasModel> get currentCanvas => _currentCanvas;

  set canvasStates(List<ImageState> replayImagesState) {
    _canvasStates = replayImagesState;
    notifyListeners();
  }

  set currentCanvas(Future<CanvasModel> canvas) {
    _currentCanvas = canvas;
    notifyListeners();
  }

  void addCanvasState(ImageState imageState) {
    _canvasStates.add(imageState);
    notifyListeners();
  }

  void clearCanvasStates() {
    _canvasStates.clear();
    notifyListeners();
  }

  void convertToImageState(
      int eventIndex, String base64String, bool isMainCanvas) async {
    Future<ui.Image> image = decodeBase64Image(base64String);
    addCanvasState(ImageState(
        eventIndex: eventIndex, image: image, isMainCanvas: isMainCanvas));
  }

  // Decode images at the beginning of the replay
  Future<ui.Image> decodeBase64Image(String base64String) async {
    print("On update empty ?");
    final Uint8List bytes = base64.decode(base64String);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      return completer.complete(img);
    });
    return Future.value(completer.future);
  }

  Future<void> updateCanvasState(String base64String, String eventIndex) async {
    final ImageCacheService cacheService = ImageCacheService();
    ui.Image newModifiedImage = cacheService.getImage(eventIndex) ??
        await decodeBase64Image(base64String);

    CanvasModel currentCanvasModel = await _currentCanvas;
    ui.Image originalImage = currentCanvasModel.original;

    _currentCanvas = Future<CanvasModel>.value(CanvasModel(
      original: originalImage,
      modified: newModifiedImage,
    ));
    print("here");
    notifyListeners();
  }

  static String? extractBase64Data(String dataUri) {
    final int commaIndex = dataUri.indexOf(',');

    if (commaIndex == -1) {
      print('Invalid data URI');
      return null;
    }

    return dataUri.substring(commaIndex + 1);
  }
}

class ImageCacheService {
  final Map<String, ui.Image> _cache = {};

  Future<ui.Image> decodeAndCacheBase64Image(String base64String,
      [String? cacheKey]) async {
    final Uint8List bytes = base64.decode(base64String);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    final ui.Image image = await completer.future;
    // Use a unique cache key for each image; using the base64 string itself, or a hash, etc.
    final String key = cacheKey ?? base64String;
    _cache[key] = image;
    return image;
  }

  ui.Image? getImage(String cacheKey) {
    return _cache[cacheKey];
  }

  void clearCache() {
    _cache.clear();
  }
}
