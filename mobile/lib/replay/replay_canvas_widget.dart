import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/painters/background_pt_modified.dart';
import 'package:mobile/painters/background_pt_original.dart';
import 'package:mobile/painters/foreground_pt_modified.dart';
import 'package:mobile/painters/foreground_pt_original.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/widgets/game_canvas.dart';
import 'package:provider/provider.dart';

class ReplayOriginalCanvas extends GameCanvas {
  final GameAreaService gameAreaService = Get.find();

  ReplayOriginalCanvas(
    images,
  ) : super(images);

  @override
  Widget build(BuildContext context) {
    final gameAreaService = context.watch<GameAreaService>();

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 3.0,
            ),
          ),
          child: GestureDetector(
            onTapUp: (details) {
              return;
            },
            child: SizedBox(
              width: images.original.width.toDouble() *
                  GameCanvas.tabletScalingRatio,
              height: images.original.height.toDouble() *
                  GameCanvas.tabletScalingRatio,
              child: CustomPaint(
                painter: BackgroundPtOriginal(images),
                foregroundPainter:
                    ForegroundPtOriginal(images, gameAreaService),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReplayModifiedCanvas extends GameCanvas {
  final GameAreaService gameAreaService = Get.find();
  ReplayModifiedCanvas(
    images,
  ) : super(images);

  @override
  Widget build(BuildContext context) {
    final GameAreaService gameAreaService = context.watch<GameAreaService>();
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 3.0,
            ),
          ),
          child: GestureDetector(
            onTapUp: (details) {
              return;
            },
            child: SizedBox(
              width: images.original.width.toDouble() *
                  GameCanvas.tabletScalingRatio,
              height: images.original.height.toDouble() *
                  GameCanvas.tabletScalingRatio,
              child: CustomPaint(
                painter: BackgroundPtModified(images),
                foregroundPainter:
                    ForegroundPtModified(images, gameAreaService),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
