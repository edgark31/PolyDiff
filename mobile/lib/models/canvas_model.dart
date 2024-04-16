import 'dart:ui' as ui;

class CanvasModel {
  final ui.Image modified;
  final ui.Image original;

  const CanvasModel({
    required this.original,
    required this.modified,
  });

  CanvasModel copyWith({
    ui.Image? original,
    ui.Image? modified,
  }) {
    return CanvasModel(
      original: original ?? this.original,
      modified: modified ?? this.modified,
    );
  }

  // Static async method to create empty CanvasModel
  static Future<CanvasModel> createWithEmptyCanvas(
      int width, int height) async {
    final emptyOriginalImage = await createEmptyImage(width, height);
    final emptyModifiedImage = await createEmptyImage(width, height);

    return CanvasModel(
      original: emptyOriginalImage,
      modified: emptyModifiedImage,
    );
  }
}

Future<ui.Image> createEmptyImage(int width, int height) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint();

  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    paint..color = ui.Color(0x00000000),
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(width, height);

  return img;
}
