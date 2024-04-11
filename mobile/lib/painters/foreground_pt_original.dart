import 'package:flutter/material.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/widgets/game_canvas.dart';

class ForegroundPtOriginal extends CustomPainter {
  final GameAreaService gameAreaService;
  final CanvasModel images;

  ForegroundPtOriginal(this.images, this.gameAreaService);

  @override
  void paint(Canvas canvas, Size size) {
    if (gameAreaService.blinkingDifference != null) {
      canvas.scale(
          GameCanvas.tabletScalingRatio, GameCanvas.tabletScalingRatio);

      canvas.drawPath(
          gameAreaService.blinkingDifference!, gameAreaService.blinkingColor);
    }

    if (gameAreaService.cheatBlinkingDifference != null) {
      canvas.scale(
          GameCanvas.tabletScalingRatio, GameCanvas.tabletScalingRatio);

      canvas.drawPath(gameAreaService.cheatBlinkingDifference!,
          gameAreaService.blinkingColor);
    }

    if (gameAreaService.leftErrorCoord.isNotEmpty) {
      canvas.scale(
          GameCanvas.tabletScalingRatio, GameCanvas.tabletScalingRatio);
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'X',
          style: TextStyle(
            color: Colors.red,
            fontSize: 60.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((gameAreaService.leftErrorCoord[0].x - 17).toDouble(),
            (gameAreaService.leftErrorCoord[0].y - 30).toDouble()),
      );
      print(
          'drawn: x: ${gameAreaService.leftErrorCoord[0].x} y:${gameAreaService.leftErrorCoord[0].y}');
      gameAreaService.leftErrorCoord = [];
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
