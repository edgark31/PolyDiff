import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mobile/painters/background_pt_modified.dart';
import 'package:mobile/painters/background_pt_original.dart';
import 'package:mobile/painters/foreground_pt_original.dart';
import 'package:mobile/widgets/game_canvas.dart';

class OriginalCanvas extends GameCanvas {
  OriginalCanvas(images, this.gameId) : super(images);
  final String gameId;

  @override
  Widget build(BuildContext context) {
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
              x.value = details.localPosition.dx.toDouble() /
                  GameCanvas.tabletScalingRatio;
              y.value = details.localPosition.dy.toDouble() /
                  GameCanvas.tabletScalingRatio;
              // Send coords
            },
            child: SizedBox(
              width: images.original.width.toDouble() *
                  GameCanvas.tabletScalingRatio,
              height: images.original.height.toDouble() *
                  GameCanvas.tabletScalingRatio,
              child: CustomPaint(
                painter: BackgroundPtOriginal(images),
                foregroundPainter: ForegroundPtOriginal(images),
              ),
            ),
          ),
        ),
        Obx(
          () => Text("Coordinate x : ${x.value}, y : ${y.value}"),
        )
      ],
    );
  }
}

class ModifiedCanvas extends GameCanvas {
  ModifiedCanvas(images, this.gameId) : super(images);
  final String gameId;

  @override
  Widget build(BuildContext context) {
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
              print('canvas tapped');
              x.value = details.localPosition.dx.toDouble() /
                  GameCanvas.tabletScalingRatio;
              y.value = details.localPosition.dy.toDouble() /
                  GameCanvas.tabletScalingRatio;
              //Send coords
            },
            child: SizedBox(
              width: images.original.width.toDouble() *
                  GameCanvas.tabletScalingRatio,
              height: images.original.height.toDouble() *
                  GameCanvas.tabletScalingRatio,
              child: CustomPaint(
                painter: BackgroundPtModified(images),
                foregroundPainter: ForegroundPtOriginal(images),
              ),
            ),
          ),
        ),
        Obx(
          () => Text("Coordinate x : ${x.value}, y : ${y.value}"),
        )
      ],
    );
  }
}
