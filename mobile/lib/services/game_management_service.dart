import 'package:flutter/material.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/capture_game_events_service.dart';
import 'package:mobile/services/socket_service.dart';

class GameManagerService with ChangeNotifier {
  final SocketService _socketService;
  final CaptureGameEventsService _captureService = CaptureGameEventsService();

  GameManagerService(this._socketService) {
    _socketService.on<GameEvents>(SocketType.Game, 'gameEvent', (data) {
      notifyListeners();
    });
  }

  void startGame() {
    _socketService.send(SocketType.Game, 'startGame');
  }

  void foundDifference(Coordinate coordinates) {
    _captureService.saveReplayEvent(GameEvents.Found, coordinates);
    _socketService.send(SocketType.Game, 'findDifference', coordinates);
  }

  void gameModeChanged(GameModes mode) {
    _socketService.send(SocketType.Game, 'changeGameMode', mode);
  }

  void gameEnded() {
    _socketService.send(SocketType.Game, 'endGame');
  }

  void startNextGame() {
    _socketService.send(SocketType.Game, GameEvents.StartNextGame.name);
  }

  void requestVerification(Coordinate coords) {
    _socketService.send(
        SocketType.Game, GameEvents.RemoveDifference.name, coords);
  }

  void abandonGame() {
    _socketService.send(SocketType.Game, GameEvents.AbandonGame.name);
  }

  void requestHint() {
    _socketService.send(SocketType.Game, GameEvents.RequestHint.name);
  }

  // void requestReplay() {
  //   _socketService.send(SocketType.Game, GameEvents.RequestReplay.name);
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
