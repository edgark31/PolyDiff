import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/record_model.dart';
import 'package:mobile/replay/replay_data_provider.dart';
import 'package:mobile/replay/replay_game_model.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:provider/provider.dart';

class ReplayManagerService {
  GameManagerService gameManagerService = Get.find();
  GameAreaService gameAreaService = Get.find();
  GameRecord? _gameRecord;

  void handleEvent(GameEvent event) {
    switch (event.gameEvent) {
      case 'StartGame':
        startGame();

      case 'Click':
        click(event.username, event.coordinates!, event.isMainCanvas!);

      case 'Found':
        found(event.username, event.coordinates!);
      case 'NotFound':
        notFound(event.username, event.coordinates!);

      case 'CheatActivated':
        cheatActivated(event.username);

      case 'CheatDeactivated':
        cheatDeactivated(event.username);

      case 'EndGame':
        endGame();

      default:
        print('Unknown event: ${event.gameEvent}');
    }
  }

  // void loadGameRecord(GameRecord gameRecord) {
  //   _gameRecord = gameRecord;
  // }

  // Only for testing purposes
  //Get JSON
  Future getJsonProverb() async {
    final String rawJson = await rootBundle.loadString('assets/json/data.json');
    return await jsonDecode(rawJson);
  }

  void loadGameRecord() {
    GameRecord gameRecordTest = getJsonProverb() as GameRecord;
    print('*** GAME RECORD FROM JSON *** : $gameRecordTest');
    _gameRecord = gameRecordTest;
  }

  void replayGame() {
    if (_gameRecord == null) {
      print('No game record loaded.');
      return;
    }

    DateTime gameStart = DateTime.parse(_gameRecord!.startTime);

    for (var event in _gameRecord!.gameEvents) {
      DateTime eventTime = DateTime.parse(event.timestamp);
      Duration delay = eventTime.difference(gameStart);
      Timer(delay, () => handleEvent(event));
    }
  }

  // TODO: call gameService when implemented
  void startGame() {
    print('Game started');
    gameManagerService.setGame(_gameRecord!.game);
  }

  void click(String username, Coordinate coordinates, bool isMainCanvas) {
    print(
        '$username clicked at $coordinates on ${isMainCanvas ? 'main' : 'secondary'} canvas');
  }

  void found(String username, Coordinate coordinates) {
    print('$username found a difference at $coordinates');
  }

  void notFound(String username, Coordinate coordinates) {
    print('$username did not find a difference at $coordinates');
  }

  void cheatActivated(String username) {
    print('$username activated cheat');
  }

  void cheatDeactivated(String username) {
    print('$username deactivated cheat');
  }

  void endGame() {
    print('Game ended');
  }

  void resetGameArea(BuildContext context) {
    ReplayDataProvider replayDataProvider =
        Provider.of<ReplayDataProvider>(context, listen: false);

    for (int i = 0; i < replayDataProvider.displayDifferences.length; i++) {
      replayDataProvider.updateDisplayDifferences(
          i, Difference(coordinates: []));
    }
    replayDataProvider.resetDifference();
  }
}
