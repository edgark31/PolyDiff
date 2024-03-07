import 'package:flutter/material.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/widgets/game_canvas.dart';

// TODO: Make calls for validation
class ForegroundPtOriginal extends CustomPainter {
  final CanvasModel images;

  ForegroundPtOriginal(this.images); //

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(GameCanvas.tabletScalingRatio, GameCanvas.tabletScalingRatio);

    final path = Path();
    /*for (var coord in diffService.coordinates) {
      path.addRect(Rect.fromPoints(
          Offset(coord.x.toDouble(), coord.y.toDouble()),
          Offset(coord.x + 1, coord.y + 1)));
    }
    canvas.clipPath(path);
    canvas.drawImage(images.modified, Offset.zero, Paint());

    if (diffService.blinkingDifference != null) {
      canvas.drawPath(
          diffService.blinkingDifference!, diffService.defaultBlinkingColor);
    }*/
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
