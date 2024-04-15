import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/services/game_area_service.dart';

typedef ReplayCompletionCallback = void Function();
typedef GamePlaybackCompletionCallback = void Function();

class PlaybackService extends ChangeNotifier {
  final GameAreaService _gameAreaService = Get.find();
  final GameRecordProvider _gameRecordProvider = Get.find();
  late final StreamController<GameEventData> _eventsController;
  ReplayCompletionCallback? onPlaybackComplete;
  GamePlaybackCompletionCallback? onGamePlaybackComplete;

  bool _isPaused = false;
  bool _isUserInteraction = false;
  bool _isRestart = false;
  bool _isFromProfile = false;

  DateTime? _lastEventTime;
  Timer? _timer;
  int _currentIndex = 0;
  double _speed = SPEED_X1;

  Stream<GameEventData> get eventsStream => _eventsController.stream;
  List<GameEventData> get events => _gameRecordProvider.record.gameEvents;
  DateTime? get lastEventTime => _lastEventTime;

  double get speed => _speed;
  int get currentIndex => _currentIndex;

  bool get isPaused => _isPaused;
  bool get isUserInteraction => _isUserInteraction;
  bool get isRestart => _isRestart;

  GameEventPlaybackService() {
    _gameRecordProvider.addListener(_handleProviderUpdate);
    _eventsController = StreamController<GameEventData>.broadcast(
      onListen: () {},
      onCancel: _stopPlayback,
    );

    if (events.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        _playbackEvents();
      });
    }
  }

  void _handleProviderUpdate() {
    if (_gameRecordProvider.isFromProfile != _isFromProfile) {
      _isFromProfile = _gameRecordProvider.isFromProfile;
      notifyListeners();
    }
  }

  void startPlayback() {
    if (!_isPaused && events.isNotEmpty) {
      print("Starting playback from the beginning.");
      _gameAreaService.reset();
      _currentIndex = 0;
      _isUserInteraction = false;
      _isRestart = false;
      _isPaused = false;
      _speed = SPEED_X1;
      _lastEventTime = null;
      _playbackEvents();
    }
  }

  void setIsUserInteraction(bool value) {
    _isUserInteraction = value;
  }

  void restart() async {
    pause();
    await Future.delayed(Duration(milliseconds: 500), () {
      _gameAreaService.reset();
      _currentIndex = 0;
      _isRestart = true;
      _speed = SPEED_X1;
      print("Restarting playback from start. Current index set to 0.");
      resume();
      _isRestart = false;
    });
  }

  void resume() {
    print("Resuming playback.");
    _gameAreaService.resumeAnimation();
    _isPaused = false;
    _playbackEvents();
  }

  void pause() {
    _gameAreaService.pauseAnimation();
    _isPaused = true;
    print("Playback paused.");
  }

  void _playbackEvents() async {
    if (events.isEmpty) {
      print("No events to play.");
      return;
    }

    if (_isPaused) {
      print("Playback is paused, exiting playback loop.");
      return;
    }

    while (_currentIndex < events.length && !_isPaused) {
      final GameEventData event = events[_currentIndex];
      final DateTime previousEventTime = _currentIndex == 0
          ? event.timestamp
          : events[_currentIndex - 1].timestamp;
      final int durationSinceLastEvent =
          event.timestamp.difference(previousEventTime).inMilliseconds;

      if (!_isUserInteraction && !_isRestart) {
        if (durationSinceLastEvent > 0) {
          await Future.delayed(Duration(
              milliseconds: (durationSinceLastEvent / _speed).floor()));
        }

        if (_isPaused) {
          print("Playback paused during delay at index $_currentIndex.");
          return;
        }

        _eventsController.sink.add(event);
        print("Event added to stream: ${event.gameEvent}");
        _currentIndex++;
      }

      if (_isRestart) {
        print("Restart flag detected during playback at index $_currentIndex.");
        _currentIndex = 0;
        _isRestart = false;
        continue;
      }
    }

    if (_currentIndex >= events.length && !_isPaused) {
      if (onPlaybackComplete != null && _isFromProfile) {
        onPlaybackComplete!();
      } else if (onGamePlaybackComplete != null && !_isFromProfile) {
        onGamePlaybackComplete!();
      } else {
        print("Playback completed or paused.");
      }
    }
  }

  void setOnPlaybackComplete(ReplayCompletionCallback callback) {
    onPlaybackComplete = callback;
  }

  void setGamePlaybackComplete(GamePlaybackCompletionCallback callback) {
    onGamePlaybackComplete = callback;
  }

  void setSpeed(double speed) async {
    _speed = speed;
    print("Speed set to $_speed. Adjusting playback speed.");
    if (!_isPaused) {
      pause();
      await Future.delayed(Duration(milliseconds: 500));

      resume();
    }
    notifyListeners();
  }

  void seekToEvent(int eventIndex) {
    if (eventIndex < 0 || eventIndex >= events.length) {
      print("Invalid event index: $eventIndex");
      return;
    }

    print("Seeking to event index: $eventIndex");
    _isUserInteraction = true;

    pause();

    // Resume playback with a slight delay to allow the UI to update
    Future.delayed(Duration(milliseconds: 500), () {
      _currentIndex = eventIndex;
      if (!_isPaused) {
        resume();
      }
      _isUserInteraction = false;
    });
  }

  void _stopPlayback() {
    print("Stopping playback.");
    _gameAreaService.reset();
    _currentIndex = 0;
    _lastEventTime = null;
    _speed = SPEED_X1;
    _isPaused = true;
    _timer?.cancel();
  }

  int calculateEventIndexFromSliderPosition(
      double sliderPosition, List<GameEventData> events) {
    if (events.isEmpty) return 0;

    final totalDuration =
        events.last.timestamp.difference(events.first.timestamp).inMilliseconds;
    final targetTime = events.first.timestamp
        .add(Duration(milliseconds: (totalDuration * sliderPosition).round()));

    for (int i = 0; i < events.length; i++) {
      if (events[i].timestamp.compareTo(targetTime) >= 0) {
        return i;
      }
    }
    return events.length - 1;
  }

  @override
  void dispose() {
    _gameRecordProvider.removeListener(_handleProviderUpdate);
    _stopPlayback();
    _eventsController.close();
    super.dispose();
  }
}
