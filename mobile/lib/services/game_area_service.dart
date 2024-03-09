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

  void showDifferenceFound(List<Coordinate> newCoordinates) {
    // _soundService.playDifferenceFound();
    print('enters showDifferenceFound');
    coordinates.addAll(newCoordinates);
    notifyListeners();
    startBlinking(newCoordinates);
  }

  /*void showDifferenceNotFound() {
    _soundService.playDifferenceNotFound();
    print("difference not found");
  }*/

  /*void showError(dynamic message) {
    _soundService.playDifferenceNotFound();
    print(message);
    print("SocketEvent.error");
  }*/

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
    const int timeToBlinkMs = 500;

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

  void resetForNextGame() {
    blinkingDifference = null;
    coordinates = [];
  }

  /*bool validate(Vec2 mousePosition, String gameId, bool isOriginal) {
    if (mousePosition.x < 0 || mousePosition.y < 0) return false;
    try {
      final data = DifferenceFoundRequest(
          differenceCoord: mousePosition,
          gameId: gameId,
          isOriginal: isOriginal,
          playerName: _gameManagerService.currentUser!.name);

      _socket.send(SocketEvent.difference, data.toJson());
    } catch (error) {
      print('Error while sending the request: $error');
    }
    return true;
  }*/

  showDifference(Canvas canvas) {
    final path = Path();
    for (var coord in coordinates) {
      path.addRect(Rect.fromPoints(
          Offset(coord.x.toDouble(), coord.y.toDouble()),
          Offset(coord.x + 1, coord.y + 1)));
    }
    canvas.clipPath(path);
  }

  void addNewCoords(List<Coordinate> coords) {
    coordinates.addAll(coords);
    notifyListeners();
  }
}
