import 'dart:ui' as ui;

class CanvasModel {
  final ui.Image modified;
  final ui.Image original;

  const CanvasModel({
    required this.original,
    required this.modified,
  });
}
