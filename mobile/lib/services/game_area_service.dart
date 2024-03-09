import 'package:flutter/material.dart';
import 'package:mobile/models/models.dart';

class GameAreaService extends ChangeNotifier {
  //final SoundService _soundService = Get.find();

  GameAreaService();

  List<Coordinate> coordinates = [];
  Path? blinkingDifference;
  Paint defaultBlinkingColor = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.fill;

  void validateCoord(
      Coordinate coord, List<Coordinate> coordList, bool isLeft) {
    if (coordList.contains(coord)) {
      showDifferenceFound(coordList);
    } else {
      if (isLeft) {
        print("ERROR on left canvas");
      } else {
        print("ERROR on right canvas");
      }
    }
  }

  void showDifferenceFound(List<Coordinate> newCoordinates) {
    // _soundService.playDifferenceFound();
    print('enters showDifferenceFound');
    coordinates.addAll(newCoordinates);
    notifyListeners();
    startBlinking(newCoordinates);
  }

  void showDifferenceNotFound() {
    //_soundService.playDifferenceNotFound();
  }

  void initDataToBlink(List<Coordinate> coords) {
    print('enters initDataToBlink');
    final path = Path();
    for (var coord in coords) {
      path.addRect(Rect.fromPoints(
          Offset(coord.x.toDouble(), coord.y.toDouble()),
          Offset(coord.x + 1, coord.y + 1)));
    }
    blinkingDifference = path;
  }

  Future<void> startBlinking(List<Coordinate> coords) async {
    print('enters startBlinking');
    initDataToBlink(coords);
    if (blinkingDifference == null) return;

    final Path blinkingPath = blinkingDifference!;
    const int timeToBlinkMs = 100;

    for (int i = 0; i < 3; i++) {
      await showDifferenceAndWait(blinkingPath, timeToBlinkMs);
      await hideDifference(timeToBlinkMs);
    }

    resetBlinkingDifference();
  }

  Future<void> showDifferenceAndWait(Path difference, int waitingTimeMs) async {
    print('enters showDifferenceAndWait');
    blinkingDifference = difference;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: waitingTimeMs));
  }

  Future<void> hideDifference(int waitingTimeMs) async {
    print('enters hideDifference');
    blinkingDifference = null;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: waitingTimeMs));
  }

  void resetBlinkingDifference() {
    blinkingDifference = null;
    notifyListeners();
  }
}
