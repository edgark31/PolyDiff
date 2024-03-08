import 'package:flutter/material.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/widgets/game_canvas.dart';

//TODO: Make calls for validation
class ForegroundPtModified extends CustomPainter {
  final CanvasModel images;

  ForegroundPtModified(this.images); //

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(GameCanvas.tabletScalingRatio, GameCanvas.tabletScalingRatio);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
