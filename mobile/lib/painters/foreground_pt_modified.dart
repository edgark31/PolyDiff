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
    canvas.scale(GameCanvas.tabletScalingRatio, GameCanvas.tabletScalingRatio);

    if (gameAreaService.cheatBlinkingDifference != null) {
      canvas.drawPath(gameAreaService.cheatBlinkingDifference!,
          gameAreaService.blinkingColor);
    }

    canvas.save();

    final path = Path();
    for (var coord in gameAreaService.coordinates) {
      path.addRect(Rect.fromPoints(
          Offset(coord.x.toDouble(), coord.y.toDouble()),
          Offset(coord.x + 1, coord.y + 1)));
    }
    canvas.clipPath(path);

    canvas.drawImage(images.original, Offset.zero, Paint());

    canvas.restore();

    if (gameAreaService.blinkingDifference != null) {
      canvas.drawPath(
          gameAreaService.blinkingDifference!, gameAreaService.blinkingColor);
    }

    if (gameAreaService.rightErrorCoord.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'ERREUR',
          style: TextStyle(
            color: Colors.red,
            fontSize: 30.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((gameAreaService.rightErrorCoord[0].x - 40).toDouble(),
            (gameAreaService.rightErrorCoord[0].y).toDouble()),
      );
      gameAreaService.rightErrorCoord = [];
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
