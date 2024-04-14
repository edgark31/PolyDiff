import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/game_events_services.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/info_service.dart';

class GameEventPlaybackManager extends ChangeNotifier {
  late StreamSubscription<GameEventData> _subscription;

  final GameRecordProvider _gameRecordProvider = Get.find();
  final GameAreaService _gameAreaService = Get.find();
  final ReplayPlayerProvider _replayPlayerProvider = Get.find();
  final ReplayImagesProvider replayImagesProvider = Get.find();
  final InfoService _infoService = Get.find();
  final GameEventPlaybackService _playbackService = Get.find();

  bool _isEndGame = false;
  bool _isDifferenceFound = false;
  bool _isCheatMode = false;
  bool _hasCheatModeEnabled = false;

  int _nDifferencesFound = 0;
  int _timer = 0;
  double _replaySpeed = SPEED_X1;

  bool get isEndGame => _isEndGame;
  bool get isDifferenceFound => _isDifferenceFound;
  bool get isCheatMode => _isCheatMode;

  bool get hasCheatModeEnabled => _hasCheatModeEnabled;
  int get nDifferencesFound => _nDifferencesFound;
  int get timer => _timer;

  List<Coordinate> _remainingCoordinates = [];

  List<GameEventData> get events => _gameRecordProvider.record.gameEvents;

  List<Coordinate> get remainingCoordinates => _remainingCoordinates;

  GameEventPlaybackManager() {
    _subscription = _playbackService.eventsStream.listen((event) {
      _replaySpeed = _playbackService.speed;

      _handleGameEvent(event);
    }, onError: (error) {
      print("Error in stream subscription: $error");
    });
  }

  // Event Handlers
  void _handleGameEvent(GameEventData recordedEventData) {
    print("Called Handling Game Event: ${recordedEventData.gameEvent}");
    switch (recordedEventData.gameEvent) {
      case "StartGame":
        _handleGameStartEvent();
        break;
      case "Found":
        _handleClickFoundEvent(recordedEventData);
        break;

      case "NotFound":
        _handleClickErrorEvent(recordedEventData);
        break;

      case "CheatActivated":
        _handleActivateCheatEvent(recordedEventData);
        break;

      case "CheatDeactivated":
        _handleDeactivateCheatEvent(recordedEventData);
        break;

      case "TimerUpdate":
        _handleUpdateTimerEvent(recordedEventData);
        break;

      case "EndGame":
        _handleEnGameEvent(recordedEventData);
        break;

      case "Spectate":
        _handleObserversEvent(recordedEventData);
        break;

      default:
        print("Unknown event type: ${recordedEventData.gameEvent}");
    }
  }

  void _handleGameStartEvent() {
    _gameAreaService.coordinates = [];
    _replayPlayerProvider.resetScore();
    _replayPlayerProvider.setPlayersData(_gameRecordProvider.record.players);
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
        _gameRecordProvider.record.game.differences![currentIndex],
        _replaySpeed);

    if (recordedEventData.players != null) {
      for (Player player in recordedEventData.players!) {
        _replayPlayerProvider.updatePlayerData(player);
      }
    }

    _nDifferencesFound++;
    print(
        "Difference found from GameEventPlaybackManager at index: $currentIndex");

    _handleRemainingDifferenceIndex(recordedEventData);
  }

  void _handleClickErrorEvent(GameEventData recordedEventData) {
    if (_gameRecordProvider.record.game.differences == null) return;
    if (recordedEventData.coordClic == null) return;
    if (recordedEventData.accountId != _infoService.id) return;

    _gameAreaService.showDifferenceNotFound(recordedEventData.coordClic!,
        recordedEventData.isMainCanvas!, _replaySpeed);
    notifyListeners();
  }

  void _handleActivateCheatEvent(GameEventData recordedEventData) {
    _isCheatMode = false;
    _handleRemainingDifferenceIndex(recordedEventData);
    _gameAreaService.isCheatMode = false;
    _gameAreaService.toggleCheatMode(_remainingCoordinates, _replaySpeed);
    notifyListeners();
  }

  void _handleDeactivateCheatEvent(GameEventData recordedEventData) {
    _isCheatMode = true;
    _handleRemainingDifferenceIndex(recordedEventData);
    _gameAreaService.isCheatMode = true;

    print(
        "toggle cheat mode from GameEventPlaybackManager with speed $_replaySpeed");

    _gameAreaService.toggleCheatMode(_remainingCoordinates, _replaySpeed);
    notifyListeners();
  }

  void _handleRemainingDifferenceIndex(GameEventData recordedEventData) {
    List<Coordinate> remainingCoordinates = [];

    if (recordedEventData.remainingDifferenceIndex != null &&
        recordedEventData.remainingDifferenceIndex!.isNotEmpty) {
      for (int index in recordedEventData.remainingDifferenceIndex!) {
        print("Index: $index");
        List<Coordinate> differencesAtIndex =
            _gameRecordProvider.record.game.differences![index];

        remainingCoordinates.addAll(differencesAtIndex);
      }
    } else {
      remainingCoordinates = _gameRecordProvider.record.game.differences!
          .expand((element) => element)
          .toList();
    }

    _handleUpdateRemainingDifference(remainingCoordinates);

    notifyListeners();
  }

  void _handleUpdateRemainingDifference(List<Coordinate> remaining) {
    _remainingCoordinates = remaining;
    notifyListeners();
  }

  void _handleUpdateTimerEvent(GameEventData recordedEventData) {
    _timer = recordedEventData.time!;
    notifyListeners();
  }

  void _handleObserversEvent(GameEventData recordedEventData) {
    _replayPlayerProvider
        .updateNumberOfObservers(recordedEventData.observers!.length);
    notifyListeners();
  }

  void _handleEnGameEvent(GameEventData recordedEventData) {
    _isEndGame = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer = 0;
    _isEndGame = false;
    _isDifferenceFound = false;
    _isCheatMode = false;
    _nDifferencesFound = 0;
    _remainingCoordinates = [];
    _replaySpeed = SPEED_X1;
    _gameRecordProvider.dispose();
    _playbackService.dispose();
    _gameAreaService.dispose();
    _subscription.cancel();
    super.dispose();
  }
}
