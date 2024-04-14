import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/services/game_area_service.dart';

class GameEventPlaybackService extends ChangeNotifier {
  final GameRecordProvider _gameRecordProvider = Get.find();
  final GameAreaService _gameAreaService = Get.find();
  late final StreamController<GameEventData> _eventsController;

  bool _isPaused = false;
  bool _isUserInteraction = false;
  bool _isRestart = false;

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

  void startPlayback() {
    if (!_isPaused && events.isNotEmpty) {
      _playbackEvents();
    }
  }

  void setIsUserInteraction(bool value) {
    _isUserInteraction = value;
  }

  void pause() {
    if (_isPaused) return;
    print("Playback paused.");
    _gameAreaService.pauseAnimation();
    _isPaused = true;
    _timer?.cancel();
    _isUserInteraction = true;

    notifyListeners();
  }

  void resume() {
    if (!_isPaused) return;
    _gameAreaService.resumeAnimation();

    _isUserInteraction = false;
    _isPaused = false;

    print("Resuming playback.");
    notifyListeners();
    _playbackEvents();
  }

  void restart() {
    _gameAreaService.resetCheatMode();

    _isRestart = true;
    _currentIndex = 0;

    _timer?.cancel();
    _isUserInteraction = true;

    _speed = SPEED_X1;
    _currentIndex = 0;
    print("Restarting playback from start.");

    _isUserInteraction = false;
    notifyListeners();

    _playbackEvents();
  }

  void setSpeed(double speed) {
    _speed = speed;
    if (!_isPaused) {
      pause();
      resume();
    } else if (_isPaused) {
      resume();
    }
    notifyListeners();
  }

  void _playbackEvents() async {
    if (events.isEmpty || _isPaused) {
      print("No events to play or playback is paused.");
      return;
    }

    print("Starting playback from index $_currentIndex.");
    for (int i = _currentIndex; i < events.length && !_isPaused; i++) {
      final GameEventData event = events[i];
      final DateTime previousEventTime =
          i == 0 ? event.timestamp : events[i - 1].timestamp;
      final int durationSinceLastEvent =
          event.timestamp.difference(previousEventTime).inMilliseconds;

      if (!_isUserInteraction) {
        // Only update if no user interaction is happening
        if (durationSinceLastEvent > 0) {
          await Future.delayed(Duration(
              milliseconds: (durationSinceLastEvent / _speed).floor()));
        }

        if (_isPaused) {
          _currentIndex = i;
        }

        print("Playback was paused during the delay.");
        if (_isRestart) {
          _currentIndex = 0;
        }

        _eventsController.sink.add(event);
        print("Event added to stream: ${event.gameEvent}");
      }

      _lastEventTime = event.timestamp;
      _currentIndex = i + 1;
    }

    if (_currentIndex >= events.length) {
      print("All events have been played.");
      _currentIndex = 0;
    }
  }

  // Modify the GameEventPlaybackService to handle seeking
  void seekToEvent(int eventIndex) {
    if (eventIndex < 0 || eventIndex >= events.length) {
      print("Invalid event index: $eventIndex");
      return;
    }

    print("Seeking to event index: $eventIndex");
    _isUserInteraction = true; // Set user interaction flag

    pause(); // Pause playback before changing the index
    _currentIndex = eventIndex;

    // Resume playback with a slight delay to allow the UI to update
    Future.delayed(Duration(milliseconds: 100), () {
      if (!_isPaused) {
        resume();
      }
      _isUserInteraction = false; // Reset user interaction flag after resuming
    });
  }

  void _stopPlayback() {
    print("Stopping playback.");
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
    _gameRecordProvider.dispose();
    _stopPlayback();
    _eventsController.close();
    super.dispose();
  }
}
