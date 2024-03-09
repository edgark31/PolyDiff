import 'package:flutter/material.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/widgets/game_canvas.dart';

class ForegroundPtModified extends CustomPainter {
  final GameAreaService gameAreaService;
  final CanvasModel images;

  ForegroundPtModified(this.images, this.gameAreaService);

  @override
  void paint(Canvas canvas, Size size) {
    if (gameAreaService.blinkingDifference != null) {
      canvas.scale(
          GameCanvas.tabletScalingRatio, GameCanvas.tabletScalingRatio);
      canvas.drawPath(gameAreaService.blinkingDifference!,
          gameAreaService.blinkingColor);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
