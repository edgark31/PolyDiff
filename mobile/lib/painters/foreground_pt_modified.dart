import 'package:flutter/material.dart';
import 'package:mobile/models/canvas_model.dart';

//TODO: Make calls for validation
class ForegroundPtOriginal extends CustomPainter {
  final CanvasModel images;

  ForegroundPtOriginal(this.images); //

  @override
  void paint(Canvas canvas, Size size) {
    /*if (diffService.blinkingDifference != null) {
      canvas.scale(
          GameVignette.tabletScalingRatio, GameVignette.tabletScalingRatio);
      canvas.drawPath(
          diffService.blinkingDifference!, diffService.defaultBlinkingColor);
    }*/
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
