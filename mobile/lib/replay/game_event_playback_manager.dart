import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/game_events_services.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/info_service.dart';

class GameEventPlaybackManager extends ChangeNotifier {
  late StreamSubscription<GameEventData> _subscription;

  final InfoService _infoService = Get.find();
  final GameRecordProvider _gameRecordProvider = Get.find();
  final GameAreaService _gameAreaService = Get.find();
  final ReplayPlayerProvider _replayPlayerProvider = Get.find();
  final ReplayImagesProvider _replayImagesProvider = Get.find();
  final GameEventPlaybackService _playbackService = Get.find();

  bool _isEndGame = false;
  bool _isDifferenceFound = false;
  bool _isCheatModeActivated = false;

  int _nDifferencesFound = 0;
  int _timer = 0;

  bool get isEndGame => _isEndGame;
  bool get isDifferenceFound => _isDifferenceFound;
  bool get isCheatMode => _isCheatModeActivated;

  int get nDifferencesFound => _nDifferencesFound;
  int get timer => _timer;
  int get timeLimit => _gameRecordProvider.record.timeLimit;
  double get _replaySpeed => _playbackService.speed;

  List<Coordinate> _remainingCoordinates = [];

  List<GameEventData> get events => _gameRecordProvider.record.gameEvents;
  List<Coordinate> get remainingCoordinates => _remainingCoordinates;

  GameEventPlaybackManager() {
    _subscription = _playbackService.eventsStream.listen((event) {
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

    print("Game Start Event");
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
    if (recordedEventData.modified != null) {
      print("Click event FOUND with modified not null");
      _replayImagesProvider.updateCanvasState(recordedEventData.modified!);
    } else if (recordedEventData.modified == null) {
      print("Click event FOUND with modified null");
    }
  }

  void _handleClickErrorEvent(GameEventData recordedEventData) {
    if (_gameRecordProvider.record.game.differences == null) return;
    if (recordedEventData.coordClic == null) return;
    if (recordedEventData.accountId != _infoService.id) return;
    print("Click Error Event with accountId ${recordedEventData.accountId}");
    print("Click Error Event played with accountId ${_infoService.id}");

    _gameAreaService.showDifferenceNotFound(recordedEventData.coordClic!,
        recordedEventData.isMainCanvas!, _replaySpeed);
  }

  void _handleActivateCheatEvent(GameEventData recordedEventData) {
    _isCheatModeActivated = false;
    _handleRemainingDifferenceIndex(recordedEventData);

    _gameAreaService.toggleCheatMode(_remainingCoordinates, _replaySpeed);
    notifyListeners();
  }

  void _handleDeactivateCheatEvent(GameEventData recordedEventData) {
    _isCheatModeActivated = true;
    _handleRemainingDifferenceIndex(recordedEventData);

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
  }

  void _handleEnGameEvent(GameEventData recordedEventData) {
    _isEndGame = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
