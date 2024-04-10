import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/models/players.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/display_image_memory_util.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/replay/replay_player_util.dart';
import 'package:mobile/services/services.dart';

class ReplayService extends ChangeNotifier {
  final GameRecordProvider _gameRecordProvider = Get.find();
  final ReplayPlayerProvider _replayPlayerProvider = Get.find();
  final GameAreaService _gameAreaService = Get.find();
  final SoundService _soundService = Get.find();
  final ReplayImagesProvider _replayImagesProvider = Get.find();

  late GameRecord _record;
  late ReplayInterval _replayInterval;

  bool _isCheatMode = false;
  bool _isDifferenceFound = false;
  bool _isLoadingImages = true;

  int _replaySpeed = SPEED_X1;
  int _numberOfFoundDifferencesFound = 0;
  int _replayDifferenceFound = 0;
  int _replayTimer = 0;

  GameRecord get record => _record;
  ReplayInterval get replayInterval => _replayInterval;

  List<GameEventData> _gameEventsData = [];
  List<Coordinate> _currentDifference = [];

  bool get isCheatMode => _isCheatMode;
  bool get isDifferenceFound => _isDifferenceFound;
  bool get isLoadingImages => _isLoadingImages;

  int get replaySpeed => _replaySpeed;
  int get numberOfFoundDifferences => _numberOfFoundDifferencesFound;
  int get replayDifferenceFound => _replayDifferenceFound;

  List<GameEventData> get gameEventsData => _gameEventsData;
  List<Coordinate> get currentDifference => _currentDifference;

  int get replayTimer => _replayTimer;

  bool get isPlaying => _replayInterval.isReplaying;
  int get currentReplayIndex => _replayInterval.currentIndex;

  @override
  void dispose() {
    _gameEventsData.clear();
    _currentDifference.clear();
    super.dispose();
  }

  void setReplay(GameRecord gameRecord) {
    _record = _gameRecordProvider.record;
    _gameEventsData = _gameRecordProvider.record.gameEvents;
    _replayTimer = _gameRecordProvider.record.timeLimit;
    _replayPlayerProvider.setPlayersData(_gameRecordProvider.record.players);
    _replayInterval = getReplayInterval();
    notifyListeners();
  }

  // Use to preload the images of the game events
  Future<void> preloadGameEventImages(BuildContext context) async {
    _isLoadingImages = true;
    notifyListeners();

    for (int i = 0; i < _record.gameEvents.length; i++) {
      final event = _record.gameEvents[i];
      if (event.modified != null) {
        print("Preloading image for event $i");
        int positionComma = event.modified!.indexOf(',');
        _replayImagesProvider.eventIndexToBase64[i] =
            (event.modified!).substring(positionComma + 1);

        // preload each canvas image state
        await preCacheImageFromBase64(
            context, (event.modified!).substring(positionComma + 1));
      }
    }

    _isLoadingImages = false;
    notifyListeners();
  }

  // Manage the playback of the replay
  void fallBack(int time) {
    _replayInterval.pause();
    final gameEventsFiltered = _record.gameEvents
        .where((event) =>
            event.gameEvent == "Found" || event.gameEvent == "StartGame")
        .toList();

    // Find closest timestamp
    GameEventData? closestEvent;

    for (GameEventData event in gameEventsFiltered.reversed) {
      // Iterate in reverse to find the closest prior event
      if (event.timestamp != null &&
          event.timestamp! - _record.startTime <= time * 1000) {
        closestEvent = event;

        print(
            "**** closest event found with timestamp: ${closestEvent.timestamp} ****");
        break;
      }
    }

    if (closestEvent == null) return;

    // Find the index of the closest event
    final int closestEventIndex = _record.gameEvents.indexOf(closestEvent);
    print("**** FOUND ****");
    print("closest event found with index: $closestEventIndex");

    // Calculate the index from the found timestamp
    if (closestEventIndex != -1) {
      setIndex(closestEventIndex);

      // Actions based on the event type
      if (closestEvent.gameEvent == "StartGame") {
        _handleGameStartEvent();
        _replayPlayerProvider.resetScore();
        _replayDifferenceFound = 0;
      } else {
        for (Player player in _record.players) {
          player.count = closestEvent.players
                  ?.firstWhere((p) => p.name == player.name)
                  .count ??
              0;
          _replayPlayerProvider.updatePlayerData(player);
          print("Player ${player.name} found ${player.count} differences");
        }

        _replayImagesProvider.setCurrentCanvasImage(closestEventIndex);
        print(
            "Set in ReplayService Current canvas event with index : $closestEventIndex");
      }
      print("new time limit: ${_record.timeLimit - time}");
      setReplayTimer(_record.timeLimit - time);
      _replayInterval.resume();
    }
  }

  void start() {
    setReplay(_gameRecordProvider.record);

    _replayInterval.start();
    notifyListeners();
  }

  void pause() {
    // _toggleFlashing(true);
    _replayInterval.pause();
    notifyListeners();
  }

  void resume() {
    // _toggleFlashing(false);
    _replayInterval.resume();
    notifyListeners();
  }

  void cancel() {
    _replayInterval.cancel();

    notifyListeners();
  }

  void restart() {
    cancel();

    _replayInterval.start();

    notifyListeners();
  }

  void reset() {
    cancel();

    _replaySpeed = SPEED_X1;
    _gameEventsData.clear();
    _currentDifference.clear();
    notifyListeners();
  }

  void resetTimer() {
    _replayTimer = 0;
    _numberOfFoundDifferencesFound = 0;
    _replayDifferenceFound = 0;
    _replayPlayerProvider.resetScore();
  }

  void setSpeed(int speed) {
    _replaySpeed = speed;
    notifyListeners();
  }

  void setIndex(int index) {
    _replayInterval.setCurrentReplayIndex(index);
    notifyListeners();
  }

  void setGameEventsData(List<GameEventData> gameEventsData) {
    _gameEventsData = gameEventsData;
    notifyListeners();
  }

  void setCurrentCoordinates(List<Coordinate> currentDifference) {
    _currentDifference = currentDifference;
    notifyListeners();
  }

  void _toggleFlashing(bool isPaused) {
    if (_isCheatMode) {
      _gameAreaService.toggleCheatMode(_currentDifference, _replaySpeed);
    }
    if (_isDifferenceFound && _currentDifference.isNotEmpty) {
      _gameAreaService.startBlinking(_currentDifference, _replaySpeed);
      // // TODO: maybe it will create a bug
      // if (isPaused) {
      //   _gameAreaService.pauseAnimation();
      // } else {
      //   _gameAreaService.resumeAnimation();
      // }
    }
  }

  void _handleGameEvent(GameEventData recordedEventData) {
    switch (recordedEventData.gameEvent) {
      case "StartGame":
        _handleGameStartEvent();

      case "Found":
        _handleClickFoundEvent(recordedEventData);

      case "NotFound":
        _handleClickErrorEvent(recordedEventData);

      case "CheatActivated":
        _handleActivateCheatEvent(recordedEventData);

      case "CheatDeactivated":
        _handleDeactivateCheatEvent(recordedEventData);

      case "TimerUpdate":
        _handleUpdateTimerEvent(recordedEventData);
    }
  }

  int _getNextInterval(GameEventData recordedEventData) {
    int nextActionIndex = currentReplayIndex + 1;
    _isDifferenceFound = false;
    dynamic nextInterval = REPLAY_LIMITER;

    if (nextActionIndex < _gameEventsData.length) {
      GameEventData nextAction = _gameEventsData[nextActionIndex];
      GameEventData currentAction = _gameEventsData[currentReplayIndex];

      nextInterval =
          (((nextAction.timestamp ?? 0) - (currentAction.timestamp ?? 0)) /
              _replaySpeed);
    }

    return nextInterval;
  }

  ReplayInterval getReplayInterval() {
    return ReplayInterval(
        _gameEventsData,
        (eventData) => _handleGameEvent(_gameEventsData[currentReplayIndex]),
        _getNextInterval);
  }

  void _handleGameStartEvent() {
    _gameAreaService.coordinates = [];
    notifyListeners();
  }

  void _handleClickFoundEvent(GameEventData recordedEventData) {
    if (_gameRecordProvider.record.game.differences == null) return;
    if (recordedEventData.coordClic == null) return;

    final int currentIndex = _gameRecordProvider.record.game.differences!
        .indexWhere((difference) => difference.any((coord) =>
            coord.x == recordedEventData.coordClic!.x &&
            coord.y == recordedEventData.coordClic!.y));

    _isDifferenceFound = true;
    _gameAreaService.showDifferenceFound(
        _gameRecordProvider.record.game.differences![currentIndex]);

    _soundService.playCorrectSound();

    if (recordedEventData.players != null) {
      for (Player player in recordedEventData.players!) {
        _replayPlayerProvider.updatePlayerData(player);
      }
      _handleUpdateRemainingDifference(
          _gameRecordProvider.record.game.differences!);
    }

    _numberOfFoundDifferencesFound++;
    _handleRemainingDifferenceIndex(recordedEventData);
  }

  void _handleClickErrorEvent(GameEventData recordedEventData) {
    _gameAreaService.showDifferenceNotFound(recordedEventData.coordClic!,
        recordedEventData.isMainCanvas!, _replaySpeed);
  }

  void _handleActivateCheatEvent(GameEventData recordedEventData) {
    _isCheatMode = true;
    notifyListeners();
  }

  void _handleDeactivateCheatEvent(GameEventData recordedEventData) {
    _isCheatMode = false;
    notifyListeners();
  }

  void _handleRemainingDifferenceIndex(GameEventData recordedEventData) {
    _currentDifference.clear();

    List<List<Coordinate>> remainingCoordinates = [];

    if (recordedEventData.remainingDifferenceIndex != null &&
        recordedEventData.remainingDifferenceIndex!.isNotEmpty) {
      for (int index in recordedEventData.remainingDifferenceIndex!) {
        print("Index: $index");
        List<Coordinate> differencesAtIndex =
            _gameRecordProvider.record.game.differences![index];

        remainingCoordinates.add(differencesAtIndex);
      }

      _handleUpdateRemainingDifference(remainingCoordinates);
    }
  }

  void _handleUpdateRemainingDifference(List<List<Coordinate>> remaining) {
    notifyListeners();
  }

  void setReplayTimer(int newTime) {
    _replayTimer = newTime;
    notifyListeners();
  }

  void _handleUpdateTimerEvent(GameEventData recordedEventData) {
    _replayTimer = recordedEventData.time!;
    notifyListeners();
  }
}
