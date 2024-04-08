import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/models/players.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/player_data_provider.dart';
import 'package:mobile/replay/replay_abstract_class.dart';
import 'package:mobile/services/services.dart';

class ReplayService extends ChangeNotifier implements ReplayPlayer {
  final GameRecordProvider _gameRecordProvider = Get.find();
  final GameManagerService _gameManagerService = Get.find();
  final PlayersDataProvider _playersDataProvider = Get.find();
  final GameAreaService _gameAreaService = Get.find();
  final SoundService _soundService = Get.find();

  Timer? _timer;
  DateTime? _pauseTime;

  bool _isReplaying = false;
  bool _isCheatMode = false;
  bool _isDifferenceFound = false;

  int _replaySpeed = SPEED_X1;
  int _currentReplayIndex = 0;
  int _numberOfFoundDifferences = 0;
  int _currentTime = 0;
  late int _remainingTime;

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

  get currentTime => _currentTime;

  @override
  void dispose() {
    _gameEventsData.clear();
    _currentDifference.clear();
    _currentTime = 0;
    super.dispose();
  }

  void setCurrentGameRecord(GameRecord gameRecord) {
    _gameManagerService.setGameRecord(gameRecord);
    print("Replay : Game Record: ${_gameRecordProvider.record}");
  }

  void setUpGameReplay() {
    _gameManagerService.setIsReplay(true);
    // TODO: get rid of
    _gameRecordProvider.getDefault();

    _gameManagerService.setGame(_gameRecordProvider.record.game);
    _gameManagerService.setTime(_gameRecordProvider.record.timeLimit);

    _isReplaying = true;
    _gameEventsData = _gameRecordProvider.record.gameEvents;
    _currentReplayIndex = 0;
    _playersDataProvider.setPlayersData(_gameRecordProvider.record.players);
    notifyListeners();
  }

  @override
  void start([int delay = 0]) {
    if (!_isReplaying || _currentReplayIndex >= _gameEventsData.length) {
      _isReplaying = true;
      _processEvent(delay);
    }
  }

  @override
  void pause() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      _pauseTime = DateTime.now();
    }

    notifyListeners();
  }

  @override
  void resume() {
    if (!_isReplaying || _pauseTime == null) return;

    var now = DateTime.now();
    var elapsed = now.difference(_pauseTime!).inMilliseconds;
    _remainingTime = (_remainingTime - elapsed).clamp(0, _remainingTime);
    _pauseTime = null;

    _processEvent(_remainingTime);

    notifyListeners();
  }

  @override
  void cancel() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _isReplaying = false;
    _currentReplayIndex = 0;
    _pauseTime = null;
  }

  void restart() {
    _currentReplayIndex = 0;

    resume();

    notifyListeners();
  }

  void _processEvent([int delay = 0]) {
    if (_currentReplayIndex < _gameEventsData.length) {
      _remainingTime = delay == 0
          ? _getNextInterval(_gameEventsData[_currentReplayIndex])
          : delay;

      if (delay == 0) {
        _handleGameEvent(_gameEventsData[_currentReplayIndex]);
        _currentReplayIndex++;
      }

      _timer?.cancel(); // Ensure no previous timer is running
      _timer = Timer(Duration(milliseconds: _remainingTime), _handleTimeout);
    } else {
      cancel(); // No more events to process
    }
  }

  void _handleTimeout() {
    if (_currentReplayIndex < _gameEventsData.length) {
      _handleGameEvent(_gameEventsData[_currentReplayIndex]);
      _currentReplayIndex++;
      _processEvent();
    } else {
      cancel();
    }
  }

  void restartTimer() {
    _currentTime = 0;
    _numberOfFoundDifferences = 0;

    for (Player player in _gameRecordProvider.record.players) {
      player.count = 0;
      _playersDataProvider.updatePlayerData(player);
    }
    start();
  }

  void resetReplay() {
    _replaySpeed = SPEED_X1;
    _gameEventsData.clear();
    _currentReplayIndex = 0;
    _isReplaying = false;

    notifyListeners();
  }

  void setSpeed(int speed) {
    _replaySpeed = speed;
    notifyListeners();
  }

  void setTimer(int timer) {
    _currentTime = timer;
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
        print("Index: $index");
        List<Coordinate> differencesAtIndex =
            _gameRecordProvider.record.game.differences![index];

        remainingCoordinates.add(differencesAtIndex);
      }

      _gameManagerService.updateRemainingDifferences(remainingCoordinates);
    }
  }

  void _handleUpdateTimerEvent(GameEventData recordedEventData) {
    _currentTime = recordedEventData.time!;
    _gameManagerService.setTime(recordedEventData.time!);
  }
}
