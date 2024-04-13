import 'dart:async';

import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/services/game_area_service.dart';

class GameEventPlaybackService {
  final GameAreaService _gameAreaService = Get.find();
  late final StreamController<GameEventData> _eventsController;

  final List<GameEventData> _events;
  bool _isPaused = false;
  bool _isPlayback = false;

  DateTime? _lastEventTime;
  Timer? _timer;
  int _currentIndex = 0;
  double _speed = SPEED_X1;

  Stream<GameEventData> get eventsStream => _eventsController.stream;
  List<GameEventData> get events => _events;
  DateTime? get lastEventTime => _lastEventTime;

  double get speed => _speed;
  int get currentIndex => _currentIndex;

  bool get isPaused => _isPaused;
  bool get isPlayback => _isPlayback;

  GameEventPlaybackService(
    this._events,
  ) {
    _eventsController = StreamController<GameEventData>.broadcast(
      onListen: () {
        if (!_isPaused && _events.isNotEmpty) {
          _playbackEvents();
        }
      },
      onCancel: _stopPlayback,
    );

    if (_events.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        _playbackEvents();
      });
    }
  }

  void pause() {
    print("Playback paused.");
    _gameAreaService.pauseAnimation();
    _isPaused = true;
    _timer?.cancel();
  }

  void resume() {
    if (!_isPaused) return;
    _gameAreaService.resumeAnimation();
    _isPaused = false;

    if (_isPlayback && _events.isNotEmpty) {
      _isPlayback = false;
    }
    print("Resuming playback.");
    _playbackEvents();
  }

  void restart() {
    pause();
    _currentIndex = 0;
    _speed = SPEED_X1;
    _lastEventTime = _events.first.timestamp;
    _isPaused = false;
    _playbackEvents();
  }

  void setSpeed(double speed) {
    _speed = speed;
    if (!_isPaused) {
      pause();
      resume();
    }
  }

  void _playbackEvents() async {
    if (_events.isEmpty || _isPaused) {
      print("No events to play or playback is paused.");
      return;
    }

    for (int i = _currentIndex; i < _events.length && !_isPaused; i++) {
      final GameEventData event = _events[i];
      final DateTime previousEventTime =
          i == 0 ? event.timestamp : _events[i - 1].timestamp;
      final int durationSinceLastEvent =
          event.timestamp.difference(previousEventTime).inMilliseconds;

      // Adjust playback speed
      int adjustedPlaybackSpeed = (durationSinceLastEvent / _speed).floor();

      if (durationSinceLastEvent > 0) {
        await Future.delayed(Duration(milliseconds: adjustedPlaybackSpeed));
      }

      if (_isPaused) {
        print("Playback was paused during the delay.");
        _currentIndex = i;
        return;
      }

      _eventsController.sink.add(event);
      print("Event added to stream: ${event.gameEvent}");

      _lastEventTime = event.timestamp;
      _currentIndex = i + 1;
    }

    if (_currentIndex >= _events.length) {
      print("All events have been played.");
      _currentIndex = 0;
    }
  }

  // Modify the GameEventPlaybackService to handle seeking
  void seekToEvent(int eventIndex) {
    if (events.isEmpty || eventIndex >= events.length) return;
    _currentIndex = eventIndex;
    _isPlayback = true;
    pause();
    resume();
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

  void dispose() {
    _stopPlayback();
    _eventsController.close();
  }
}
