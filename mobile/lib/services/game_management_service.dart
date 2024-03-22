import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/capture_game_events_service.dart';
import 'package:mobile/services/socket_service.dart';

class GameManagerService with ChangeNotifier {
  final SocketService _socketService = Get.find();
  final CaptureGameEventsService _captureService = CaptureGameEventsService();

  void startGame() {
    _socketService.send(SocketType.Game, 'startGame');
  }

  void validateCoordinates(Map<String, dynamic> coordinates) {
    print("event called");
    _captureService.saveReplayEvent(GameEvent.ValidateCoords, coordinates);
    _socketService.send(SocketType.Game, 'validateCoordinates', coordinates);
    notifyListeners();
  }

  void foundDifference(Map<String, dynamic> coordinates) {
    _captureService.saveReplayEvent(GameEvent.Found, coordinates);
    _socketService.send(SocketType.Game, 'findDifference', coordinates);
    notifyListeners();
  }

  void gameModeChanged(GameModes mode) {
    _socketService.send(SocketType.Game, 'changeGameMode', mode);
  }

  void gameEnded() {
    _socketService.send(SocketType.Game, 'endGame');
  }

  void startNextGame() {
    _socketService.send(SocketType.Game, GameEvent.StartNextGame.name);
  }

  void requestVerification(Coordinate coords) {
    _socketService.send(
        SocketType.Game, GameEvent.RemoveDifference.name, coords);
  }

  void abandonGame() {
    _socketService.send(SocketType.Game, GameEvent.AbandonGame.name);
  }

  void requestHint() {
    _socketService.send(SocketType.Game, GameEvent.RequestHint.name);
  }

  // void requestReplay() {
  //   _socketService.send(SocketType.Game, GameEvent.RequestReplay.name);
  // }

  void replayGame(Replay replay) {
    for (var event in replay.events) {
      _captureService.saveReplayEvent(event.action, event.data);
      // TODO : remove when logic is done
      print('Action: ${event.action}, Timestamp: ${event.timestamp}');
    }
  }

  @override
  void dispose() {
    _captureService.dispose();
    super.dispose();
  }
}
