import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/models/players.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/player_data_provider.dart';
import 'package:mobile/replay/replay_player_util.dart';
import 'package:mobile/services/services.dart';

class ReplayService extends ChangeNotifier {
  final GameRecordProvider _gameRecordProvider = Get.find();
  final GameManagerService _gameManagerService = Get.find();
  final PlayersDataProvider _playersDataProvider = Get.find();
  final GameAreaService _gameAreaService = Get.find();
  final SoundService _soundService = Get.find();

  bool _isReplaying = false;
  bool _isCheatMode = false;
  bool _isDifferenceFound = false;

  int _replaySpeed = SPEED_X1;
  int _currentReplayIndex = 0;
  int _numberOfFoundDifferences = 0;
  int _replayTimer = 0;

  List<GameEventData> _gameEventsData = [];
  List<Coordinate> _currentDifference = [];

  bool get isReplaying => _isReplaying;
  bool get isCheatMode => _isCheatMode;
  bool get isDifferenceFound => _isDifferenceFound;

  int get replaySpeed => _replaySpeed;
  int get currentReplayIndex => _currentReplayIndex;
  int get numberOfFoundDifferences => _numberOfFoundDifferences;

  List<GameEventData> get gameEventsData => _gameEventsData;
  List<Coordinate> get currentDifference => _currentDifference;

  int get replayTimer => _replayTimer;

  @override
  void dispose() {
    _gameEventsData.clear();
    _currentDifference.clear();
    super.dispose();
  }

  void setCurrentGameRecord(GameRecord gameRecord) {
    _gameManagerService.setGameRecord(gameRecord);
    print("Replay : Game Record: ${_gameRecordProvider.record}");
  }

  void setUpGameReplay() {
    _gameManagerService.setIsReplay(true);
    _gameManagerService.setGame(_gameRecordProvider.record.game);
    _gameManagerService.setTime(_gameRecordProvider.record.timeLimit);
    _gameManagerService.setEndGameMessage(null);
    _isReplaying = true;
    _gameEventsData = _gameRecordProvider.record.gameEvents;

    notifyListeners();
  }

  void start() {
    if (_gameEventsData.isEmpty) return;
    _isReplaying = true;

    ReplayInterval replayInterval = _replayInterval();
    replayInterval.start();
  }

  void pause() {
    _replayInterval().pause();

    notifyListeners();
  }

  void restart() {
    _currentReplayIndex = 0;

    _replayInterval().resume();

    notifyListeners();
  }

  void restartTimer() {
    _replayTimer = 0;
    _numberOfFoundDifferences = 0;

    for (Player player in _gameRecordProvider.record.players) {
      player.count = 0;
      _playersDataProvider.updatePlayerData(player);
    }
    _replayInterval().start();
  }

  void resetReplay() {
    _replaySpeed = SPEED_X1;
    _gameEventsData.clear();
    _currentReplayIndex = 0;
    _isReplaying = false;

    notifyListeners();
  }

  void setReplaySpeed(int speed) {
    _replaySpeed = speed;
    notifyListeners();
  }

  void setReplayTimer(int timer) {
    _replayTimer = timer;
    notifyListeners();
  }

  void setReplayIndex(int index) {
    _currentReplayIndex = index;
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
      // TODO: maybe it will create a bug
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
    _currentReplayIndex++;
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

  ReplayInterval _replayInterval() {
    return ReplayInterval(
        _gameEventsData,
        (eventData) => _handleGameEvent(_gameEventsData[_currentReplayIndex]),
        _getNextInterval);
  }

  void _handleGameStartEvent() {
    _gameManagerService.startGame(_gameRecordProvider.record.game.lobbyId);
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
      // TODO: Add player notifier to update counter
      _gameManagerService.updateRemainingDifferences(
          _gameRecordProvider.record.game.differences);
    }

    _numberOfFoundDifferences++;
    _handleRemainingDifferenceIndex(recordedEventData);
  }

  void _handleClickErrorEvent(GameEventData recordedEventData) {
    _gameAreaService.showDifferenceNotFound(recordedEventData.coordClic!,
        recordedEventData.isMainCanvas!, _replaySpeed);
  }

  void _handleActivateCheatEvent(GameEventData recordedEventData) {
    _isCheatMode = true;
  }

  void _handleDeactivateCheatEvent(GameEventData recordedEventData) {
    _isCheatMode = false;
  }

  void _handleRemainingDifferenceIndex(GameEventData recordedEventData) {
    _currentDifference.clear();

    List<List<Coordinate>> remainingCoordinates = [];

    if (recordedEventData.remainingDifferenceIndex != null &&
        recordedEventData.remainingDifferenceIndex!.isNotEmpty) {
      for (int index in recordedEventData.remainingDifferenceIndex!) {
        List<Coordinate> differencesAtIndex =
            _gameRecordProvider.record.game.differences![index];

        remainingCoordinates.add(differencesAtIndex);
      }

      _gameManagerService.updateRemainingDifferences(remainingCoordinates);
    }
  }

  void _handleUpdateTimerEvent(GameEventData recordedEventData) {
    _replayTimer = recordedEventData.time!;
    _gameManagerService.setTime(recordedEventData.time!);
  }
}
