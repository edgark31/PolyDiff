import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/game_management_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/services/sound_service.dart';

class GameAreaService extends ChangeNotifier {
  final SoundService soundService = Get.find();
  final SocketService socketService = Get.find();
  final GameManagementService gameManagerService = Get.find();

  GameAreaService();
  Coordinate? currentCoord;
  List<Coordinate> coordinates = [];
  List<Coordinate> leftErrorCoord = [];
  List<Coordinate> rightErrorCoord = [];
  Path? blinkingDifference;
  Path? cheatBlinkingDifference;
  Paint blinkingColor = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.fill;
  bool isCheatMode = false;
  bool isClickDisabled = false;

  // This only validates the smile and the left circle
  // This won't be here when the connection between client and server is done
  void validateCoord(Coordinate coord, List<Coordinate> coordList,
      List<Coordinate> coordList2, bool isLeft) {
    currentCoord = coord;

    Map<String, dynamic> eventData = {
      'x': coord.x,
      'y': coord.y,
      'isLeft': isLeft,
    };

  
    if ((coordList.contains(coord) || coordList2.contains(coord)) &&
        !isClickDisabled) {
      if (coordList.contains(coord)) {
        showDifferenceFound(coordList);
        gameManagerService.validateCoordinates(eventData);
      } else {
        gameManagerService.foundDifference(eventData);
        showDifferenceFound(coordList2);
      }
    } else {
      if (isLeft && !isClickDisabled) {
        print("ERROR on left canvas");
        showDifferenceNotFoundLeft();
      } else if (!isLeft && !isClickDisabled) {
        print("ERROR on right canvas");
        showDifferenceNotFoundRight();
      }
    }
  }

  void showDifferenceFound(List<Coordinate> newCoordinates) {
    soundService.playCorrectSound();
    coordinates.addAll(newCoordinates);
    isCheatMode = false;
    resetCheatBlinkingDifference();
    notifyListeners();
    startBlinking(newCoordinates);
  }

  void showDifferenceNotFoundLeft() {
    isClickDisabled = true;
    soundService.playErrorSound();
    leftErrorCoord.add(currentCoord!);
    notifyListeners();
    Future.delayed(Duration(seconds: 1), () {
      leftErrorCoord = [];
      notifyListeners();
      isClickDisabled = false;
    });
  }

  showDifferenceNotFoundRight() {
    isClickDisabled = true;
    soundService.playErrorSound();
    rightErrorCoord.add(currentCoord!);
    notifyListeners();
    Future.delayed(Duration(seconds: 1), () {
      rightErrorCoord = [];
      notifyListeners();
      isClickDisabled = false;
    });
  }

  void initPath(List<Coordinate> coords) {
    final path = Path();
    for (var coord in coords) {
      path.addRect(Rect.fromLTWH(
        coord.x.toDouble(),
        coord.y.toDouble(),
        1,
        1,
      ));
    }
    blinkingDifference = path;
  }

  Future<void> startBlinking(List<Coordinate> coords) async {
    initPath(coords);
    if (blinkingDifference == null) return;

    final Path blinkingPath = blinkingDifference!;
    const int timeToBlinkMs = 100;

    for (int i = 0; i < 3; i++) {
      await showDifferenceGreen(blinkingPath, timeToBlinkMs);
      await showDifferenceYellow(blinkingPath, timeToBlinkMs);
    }

    resetBlinkingDifference();
  }

  Future<void> showDifferenceGreen(Path difference, int waitingTimeMs) async {
    blinkingColor.color = Colors.green;
    blinkingDifference = difference;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: waitingTimeMs));
  }

  Future<void> showDifferenceYellow(Path difference, int waitingTimeMs) async {
    blinkingColor.color = Colors.yellow;
    blinkingDifference = difference;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: waitingTimeMs));
  }

  void resetBlinkingDifference() {
    blinkingDifference = null;
    notifyListeners();
  }

  void initCheatPath(List<Coordinate> coords) {
    print('Enter initcheatpath');
    final cheatPath = Path();
    for (var coord in coords) {
      cheatPath.addRect(Rect.fromLTWH(
        coord.x.toDouble(),
        coord.y.toDouble(),
        1,
        1,
      ));
    }
    cheatBlinkingDifference = cheatPath;
  }

  Future<void> toggleCheatMode(List<Coordinate> coords) async {
    print('Enter toggleCheatMode');
    isCheatMode = !isCheatMode;
    if (isCheatMode) {
      initCheatPath(coords);
      if (cheatBlinkingDifference == null) return;

      final Path blinkingCheatPath = cheatBlinkingDifference!;
      const int timeToBlinkMs = 150;
      const int cheatModeWaitMs = 250;

      while (isCheatMode) {
        await showCheatDifference(blinkingCheatPath, timeToBlinkMs);
        await hideCheatDifference(cheatModeWaitMs);
        if (!isCheatMode) {
          break;
        }
      }
    } else {
      resetCheatBlinkingDifference();
      return;
    }
    resetCheatBlinkingDifference();
  }

  Future<void> showCheatDifference(Path difference, int waitingTimeMs) async {
    print('Enter showcheat');
    blinkingColor.color = Colors.red;
    cheatBlinkingDifference = difference;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: waitingTimeMs));
  }

  Future<void> hideCheatDifference(int waitingTimeMs) async {
    print('Enter hidecheat');
    blinkingColor.color = Colors.red;
    cheatBlinkingDifference = null;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: waitingTimeMs));
  }

  void resetCheatBlinkingDifference() {
    print('Enter resetcheat');
    cheatBlinkingDifference = null;
    notifyListeners();
  }
}
