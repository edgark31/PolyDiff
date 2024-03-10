import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/sound_service.dart';

class GameAreaService extends ChangeNotifier {
  final SoundService soundService = Get.put(SoundService());
  GameAreaService();
  Coordinate? currentCoord;
  List<Coordinate> coordinates = [];
  List<Coordinate> leftErrorCoord = [];
  List<Coordinate> rightErrorCoord = [];
  Path? blinkingDifference;
  Paint blinkingColor = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.fill;

  // This only validates that on the left canvas you're pressing the smile and that on the right canvas your're pressing the left circle
  void validateCoord(
      Coordinate coord, List<Coordinate> coordList, bool isLeft) {
    currentCoord = coord;
    if (coordList.contains(coord)) {
      showDifferenceFound(coordList);
    } else {
      if (isLeft) {
        print("ERROR on left canvas");
        showDifferenceNotFoundLeft();
      } else {
        print("ERROR on right canvas");
        showDifferenceNotFoundRight();
      }
    }
  }

  void showDifferenceFound(List<Coordinate> newCoordinates) {
    soundService.playCorrectSound();
    coordinates.addAll(newCoordinates);
    notifyListeners();
    startBlinking(newCoordinates);
  }

  void showDifferenceNotFoundLeft() {
    soundService.playErrorSound();
    leftErrorCoord.add(currentCoord!);
    notifyListeners();
    Future.delayed(Duration(seconds: 1), () {
      leftErrorCoord = [];
      notifyListeners();
    });
  }

  showDifferenceNotFoundRight() {
    soundService.playErrorSound();
    rightErrorCoord.add(currentCoord!);
    notifyListeners();
    Future.delayed(Duration(seconds: 1), () {
      rightErrorCoord = [];
      notifyListeners();
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
}
