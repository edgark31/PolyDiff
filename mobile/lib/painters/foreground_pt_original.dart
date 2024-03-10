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
    print('called paint in foreground');
    canvas.scale(GameCanvas.tabletScalingRatio, GameCanvas.tabletScalingRatio);
    if (gameAreaService.leftErrorCoord.isNotEmpty) {
      print('called error');
      print(gameAreaService.leftErrorCoord[0].x);
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
        Offset(gameAreaService.leftErrorCoord[0].x - 40 as double,
            gameAreaService.leftErrorCoord[0].y as double),
      );
      gameAreaService.leftErrorCoord = [];
    }
    final path = Path();
    for (var coord in gameAreaService.coordinates) {
      path.addRect(Rect.fromPoints(
          Offset(coord.x.toDouble(), coord.y.toDouble()),
          Offset(coord.x + 1, coord.y + 1)));
    }
    canvas.clipPath(path);
    canvas.drawImage(images.modified, Offset.zero, Paint());

    if (gameAreaService.blinkingDifference != null) {
      canvas.drawPath(
          gameAreaService.blinkingDifference!, gameAreaService.blinkingColor);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
