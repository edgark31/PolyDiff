import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/models/players.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/replay/replay_player_util.dart';
import 'package:mobile/services/services.dart';

class ReplayService extends ChangeNotifier {
  // Services
  final GameRecordProvider _gameRecordProvider = Get.find();
  final ReplayPlayerProvider _replayPlayerProvider = Get.find();
  final GameAreaService _gameAreaService = Get.find();
  final SoundService _soundService = Get.find();
  final ReplayImagesProvider _replayImagesProvider = Get.find();

  // Variables
  late GameRecord _record;
  late ReplayInterval _replayInterval;

  bool _isCheatMode = false;
  bool _hasCheatMode = false;
  bool _isDifferenceFound = false;
  bool _isLoadingImages = true;

  int _replaySpeed = SPEED_X1;
  int _numberOfFoundDifferencesFound = 0;
  int _currentReplayIndex = 0;
  int _replayTimer = 0;

  GameRecord get record => _record;
  ReplayInterval get replayInterval => _replayInterval;

  List<GameEventData> _gameEventsData = [];
  List<Coordinate> _currentDifference = [];

  bool get isCheatMode => _isCheatMode;
  bool get hasCheatMode => _hasCheatMode;
  bool get isDifferenceFound => _isDifferenceFound;
  // For precaching ui.Images
  bool get isLoadingImages => _isLoadingImages;

  int get replaySpeed => _replaySpeed;
  // TODO: See where this is called
  int get numberOfFoundDifferences => _numberOfFoundDifferencesFound;
  int get currentReplayIndex => _currentReplayIndex;

  List<GameEventData> get gameEventsData => _gameEventsData;
  List<Coordinate> get currentDifference => _currentDifference;

  int get replayTimer => _replayTimer;

  bool get isPlaying => _replayInterval.isReplaying;

  @override
  void dispose() {
    _gameEventsData.clear();
    _currentDifference.clear();
    _replayPlayerProvider.resetScore();
    _replayInterval.cancel();
    ImageCacheService().clearCache();
    super.dispose();
  }

  set replay(GameRecord gameRecord) {
    _record = _gameRecordProvider.record;
    _hasCheatMode = _record.isCheatEnabled;
    _gameEventsData = _gameRecordProvider.record.gameEvents;
    _replayTimer = _gameRecordProvider.record.timeLimit;
    _replayPlayerProvider.setPlayersData(_gameRecordProvider.record.players);
    _replayInterval = getReplayInterval();

    notifyListeners();
  }

  set record(GameRecord record) {
    _record = record;
    notifyListeners();
  }

  set currentIndex(int index) {
    _currentReplayIndex = index;
    notifyListeners();
  }

  set replayTimer(int newTime) {
    _replayTimer = newTime;
    notifyListeners();
  }

  set isLoadingImages(bool isLoading) {
    _isLoadingImages = isLoading;
    notifyListeners();
  }

  set speed(int speed) {
    _replaySpeed = speed;
    notifyListeners();
  }

  set gameEventsData(List<GameEventData> gameEventsData) {
    _gameEventsData = gameEventsData;
    notifyListeners();
  }

  set currentCoordinates(List<Coordinate> currentDifference) {
    _currentDifference = currentDifference;
    notifyListeners();
  }

  Future<void> loadInitialCanvas(BuildContext context) async {
    Future<CanvasModel> initialImages = ImageConverterService.fromImagesBase64(
        _record.game.original, _record.game.modified);
    _replayImagesProvider.currentCanvas = initialImages;
  }

  Future<void> preloadGameEventImages(BuildContext context) async {
    _isLoadingImages = true;

    List<Future> preloadFutures = [];

    for (int i = 0; i < _record.gameEvents.length; i++) {
      final event = _record.gameEvents[i];
      if (event.modified != null &&
          event.modified!.isNotEmpty &&
          event.gameEvent == "Found") {
        String base64Data =
            ReplayImagesProvider.extractBase64Data(event.modified!) ?? "";
        if (base64Data.isNotEmpty) {
          // Prepare and cache image without awaiting
          _replayImagesProvider.convertToImageState(
              i, base64Data, event.isMainCanvas ?? false);

          print(
              "----- Preloading image GAME EVENT : CANVAS :${event.isMainCanvas}  & EVENT ${event.gameEvent} -----");

          String cacheKey = i.toString();
          print("**** Preloading image with cache key $cacheKey ****");

          preloadFutures.add(ImageCacheService()
              .decodeAndCacheBase64Image(base64Data, cacheKey));
        }
      }
    }

    // Wait for all futures to complete
    await Future.wait(preloadFutures);

    _isLoadingImages = false;
  }

  // Manage the playback of the replay
  void fallBack(int time) {
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
        print(
            "**** closest event found with timestamp: ${event.timestamp} - ${_record.startTime} ****");
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
      _currentReplayIndex = closestEventIndex;

      // Actions based on the event type
      if (closestEvent.gameEvent == "StartGame") {
        restart();
      } else if (closestEvent.gameEvent == "Found") {
        // Update player scores
        for (Player player in _record.players) {
          player.count = closestEvent.players
                  ?.firstWhere((p) => p.name == player.name)
                  .count ??
              0;

          _replayPlayerProvider.updatePlayerData(player);
          print("Player ${player.name} found ${player.count} differences");

          // Update the remaining differences with the base64 data
          _replayImagesProvider.updateCanvasState(
              closestEvent.modified!, closestEventIndex.toString());
          print(
              "Set in ReplayService Current canvas event with index : $closestEventIndex, isMainCanvas: ${closestEvent.isMainCanvas}, modified: ${closestEvent.modified}");
        }
      }
      print("Updated time to: ${_record.timeLimit - time}");
      replayTimer = _record.timeLimit - time;
    }
  }

  void start() {
    replay = _gameRecordProvider.record;

    _replayInterval.start();
    notifyListeners();
  }

  void pause() {
    _toggleFlashing(true);
    _replayInterval.pause();
    notifyListeners();
  }

  void resume() {
    _toggleFlashing(false);
    _replayInterval.resume();
    notifyListeners();
  }

  void cancel() {
    _replayInterval.cancel();
    notifyListeners();
  }

  void restart() {
    reset();

    _replayInterval.start();
    notifyListeners();
  }

  void reset() {
    cancel();

    _replaySpeed = SPEED_X1;
    _currentDifference.clear();
    resetTimer();
    notifyListeners();
  }

  void resetTimer() {
    _replayTimer = 0;
    _numberOfFoundDifferencesFound = 0;
    _replayPlayerProvider.resetScore();
  }

  void _toggleFlashing(bool isPaused) {
    if (_isCheatMode) {
      _gameAreaService.toggleCheatMode(_currentDifference, _replaySpeed);
    }
    if (_isDifferenceFound && _currentDifference.isNotEmpty) {
      _gameAreaService.startBlinking(_currentDifference, _replaySpeed);
      if (isPaused) {
        _gameAreaService.pauseAnimation();
      } else {
        _gameAreaService.resumeAnimation();
      }
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
        (eventData) => _handleGameEvent(_gameEventsData[_currentReplayIndex]),
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

  void _handleUpdateTimerEvent(GameEventData recordedEventData) {
    _replayTimer = recordedEventData.time!;
    notifyListeners();
  }
}
