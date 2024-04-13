import 'dart:async';

import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/game_record_model.dart';

class GameEventPlaybackService {
  late final StreamController<GameEventData> _eventsController;

  final List<GameEventData> _events;
  bool _isPaused = false;
  bool _isPlayingBack = false;
  DateTime? _lastEventTime;
  Timer? _timer;
  int _currentIndex = 0;
  int _speed = SPEED_X1;

  Stream<GameEventData> get eventsStream => _eventsController.stream;
  List<GameEventData> get events => _events;
  DateTime? get lastEventTime => _lastEventTime;
  int get currentIndex => _currentIndex;
  int get speed => _speed;

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
    _isPaused = true;
    _timer?.cancel();
  }

  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    print("Resuming playback.");
    _playbackEvents();
  }

  void restart() {
    pause();
    _currentIndex = 0;
    _lastEventTime = null;
    _playbackEvents();
  }

  void setSpeed(int speed) {
    _speed = speed;
    if (!_isPaused) {
      pause();
      resume();
    }
  }

  void _playbackEvents() async {
    if (_isPlayingBack) return;
    _isPlayingBack = true;

    if (_events.isEmpty || _isPaused) {
      print("No events to play or playback is paused.");
      _isPlayingBack = false;
      return;
    }

    for (int i = _currentIndex; i < _events.length && !_isPaused; i++) {
      final GameEventData event = _events[i];
      final DateTime previousEventTime =
          i == 0 ? event.timestamp : _events[i - 1].timestamp;
      final int durationSinceLastEvent =
          event.timestamp.difference(previousEventTime).inMilliseconds;

      if (durationSinceLastEvent > 0) {
        await Future.delayed(Duration(milliseconds: durationSinceLastEvent));
      }

      if (_isPaused) {
        print("Playback was paused during the delay.");
        _currentIndex = i;
        _isPlayingBack = false;
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
    _isPlayingBack = false;
  }

  void _stopPlayback() {
    print("Stopping playback.");
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
