import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/services/image_converter_service.dart';

class ReplayImagesProvider extends ChangeNotifier {
  Future<CanvasModel>? _currentCanvas;

  Future<CanvasModel>? get currentCanvas => _currentCanvas;

  // Load the initial canvas state from the game record
  Future<void> loadInitialCanvas(GameRecord record) async {
    try {
      CanvasModel initialCanvas = await ImageConverterService.fromImagesBase64(
          record.game.original, record.game.modified);
      _currentCanvas = Future.value(initialCanvas);
      notifyListeners();
    } catch (e) {
      print('Error loading initial canvas: $e');
      rethrow;
    }
  }

  // Update the canvas state when a new event with a modified image is found
  Future<void> updateCanvasState(String base64String) async {
    var currentCanvasFuture = _currentCanvas;

    _currentCanvas = currentCanvasFuture!.then((currentCanvas) async {
      // Decode the new modified image
      ui.Image modifiedImage =
          await ImageConverterService.imageFromBase64String(base64String);

  
      if (currentCanvas.modified == modifiedImage) {
        print('Updating canvas state with new modified image.');

        return currentCanvasFuture;
      } else {
        print('Updating canvas state with new modified image.');
        return CanvasModel(
            original: currentCanvas.original, modified: modifiedImage);
      }
    }).catchError((error) {
      print('Error updating canvas state: $error');

      return currentCanvasFuture;
    });

    // Notify listeners after the future completes
    _currentCanvas!.then((_) {
      notifyListeners();
    });
  }
}
