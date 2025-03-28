import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/painters/background_pt_modified.dart';
import 'package:mobile/painters/background_pt_original.dart';
import 'package:mobile/painters/foreground_pt_modified.dart';
import 'package:mobile/painters/foreground_pt_original.dart';
import 'package:mobile/services/coordinate_conversion_service.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/game_canvas.dart';
import 'package:provider/provider.dart';

class OriginalCanvas extends GameCanvas {
  OriginalCanvas(images, this.gameId) : super(images);
  final String gameId;
  final tempGameManager = CoordinateConversionService();
  final GameAreaService gameAreaService = Get.find();
  final LobbyService lobbyService = Get.find();
  final GameManagerService gameManagerService = Get.find();

  @override
  Widget build(BuildContext context) {
    final gameAreaService = Provider.of<GameAreaService>(context);
    final lobbyService = context.watch<LobbyService>();
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
              print('original canvas tapped');
              x.value = details.localPosition.dx.toDouble() /
                  GameCanvas.tabletScalingRatio;
              y.value = details.localPosition.dy.toDouble() /
                  GameCanvas.tabletScalingRatio;
              if (!gameAreaService.isClickDisabled) {
                gameManagerService.setIsLeftCanvas(true);
                gameManagerService.sendCoord(lobbyService.lobby.lobbyId,
                    Coordinate(x: x.value.toInt(), y: y.value.toInt()));
              }
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
  final LobbyService lobbyService = Get.find();
  final GameManagerService gameManagerService = Get.find();

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    final tempGameManager = CoordinateConversionService();
    final GameAreaService gameAreaService =
        Provider.of<GameAreaService>(context);
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
              print('Modified canvas tapped');
              x.value = details.localPosition.dx.toDouble() /
                  GameCanvas.tabletScalingRatio;
              y.value = details.localPosition.dy.toDouble() /
                  GameCanvas.tabletScalingRatio;
              if (!gameAreaService.isClickDisabled) {
                gameManagerService.setIsLeftCanvas(false);
                gameManagerService.sendCoord(lobbyService.lobby.lobbyId,
                    Coordinate(x: x.value.toInt(), y: y.value.toInt()));
              }
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
        Obx(
          () => Text("Coordinate x : ${x.value}, y : ${y.value}"),
        )
      ],
    );
  }
}
