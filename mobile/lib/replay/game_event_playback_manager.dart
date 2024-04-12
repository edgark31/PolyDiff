import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/sound_service.dart';

class GameEventPlaybackManager extends ChangeNotifier {
  final GameRecordProvider _gameRecordProvider = Get.find();
  final GameAreaService _gameAreaService = Get.find();
  final SoundService _soundService = Get.find();
  final ReplayPlayerProvider _replayPlayerProvider = Get.find();
  final ReplayImagesProvider _replayImagesProvider = Get.find();

  bool _isEndGame = false;
  bool _isDifferenceFound = false;
  bool _isCheatMode = false;
  bool _hasCheatModeEnabled = false;

  int _nDifferencesFound = 0;
  int _replaySpeed = SPEED_X1;

  bool get isEndGame => _isEndGame;
  bool get isDifferenceFound => _isDifferenceFound;
  bool get isCheatMode => _isCheatMode;
  bool get hasCheatModeEnabled => _hasCheatModeEnabled;
  int get nDifferencesFound => _nDifferencesFound;
  int get replaySpeed => _replaySpeed;

  GameEventPlaybackManager._();

  static final GameEventPlaybackManager _instance =
      GameEventPlaybackManager._();

  factory GameEventPlaybackManager() => _instance;

  void handleSliderChangeValue(double sliderValue) {
    int eventIndex = sliderValue.round();

    if (eventIndex >= 0 &&
        eventIndex < _gameRecordProvider.record.gameEvents.length) {
      GameEventData recordedEventData =
          _gameRecordProvider.record.gameEvents[eventIndex];

      print(
          "called handleSliderChangeValue ! : ${recordedEventData.gameEvent}");

      _handleGameEvent(recordedEventData);
    }

    notifyListeners();
  }

  void seekToEvent(int eventIndexToSeek, List<GameEventData> events) {
    if (events.isEmpty) return;

    _handleGameEvent(events[eventIndexToSeek]);

    print("called seekToEvent ! : ${events[eventIndexToSeek].gameEvent}");
  }

  // Event Handlers
  void _handleGameEvent(GameEventData recordedEventData) {
    switch (recordedEventData.gameEvent) {
      case "StartGame":
        _handleGameStartEvent();

      case "Found":
        print("Found event");
        _handleClickFoundEvent(recordedEventData);

      case "NotFound":
        _handleClickErrorEvent(recordedEventData);

      case "CheatActivated":
        _handleActivateCheatEvent(recordedEventData);

      case "CheatDeactivated":
        _handleDeactivateCheatEvent(recordedEventData);

      case "TimerUpdate":
        _handleUpdateTimerEvent(recordedEventData);

      case "EndGame":
        _handleEnGameEvent(recordedEventData);

      case "Spectatate":
        break;
    }
  }

  void _handleGameStartEvent() {
    _gameAreaService.coordinates = [];
    notifyListeners();
  }

  void _handleClickFoundEvent(GameEventData recordedEventData) {
    // if (_gameRecordProvider.record.game.differences == null) return;
    // if (recordedEventData.coordClic == null) return;

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

    _nDifferencesFound++;
    print(
        "Difference found from GameEventPlaybackManager at index: $currentIndex");
    _replayImagesProvider.updateCanvasState(
        recordedEventData.modified!, currentIndex.toString());

    _handleRemainingDifferenceIndex(recordedEventData);
  }

  void _handleClickErrorEvent(GameEventData recordedEventData) {
    _gameAreaService.showDifferenceNotFound(recordedEventData.coordClic!,
        recordedEventData.isMainCanvas!, _replaySpeed);
    notifyListeners();
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
    notifyListeners();
  }

  void _handleUpdateRemainingDifference(List<List<Coordinate>> remaining) {
    notifyListeners();
  }

  void _handleUpdateTimerEvent(GameEventData recordedEventData) {
    print("Timer Update Event : ${recordedEventData.time}");
    notifyListeners();
  }

  // TODO: implement create a ObserverManager
  void _handleObserversEvent(GameEventData recordedEventData) {
    notifyListeners();
  }

  void _handleEnGameEvent(GameEventData recordedEventData) {
    _isEndGame = true;

    notifyListeners();
  }
}
