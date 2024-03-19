import 'package:flutter/material.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/widgets/game_canvas.dart';

class BackgroundPtModified extends CustomPainter {
  final CanvasModel images;

  BackgroundPtModified(this.images);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(GameCanvas.tabletScalingRatio, GameCanvas.tabletScalingRatio);
    canvas.drawImage(images.modified, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
