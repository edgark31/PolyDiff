import 'dart:async';

import 'package:mobile/models/game_record_model.dart';

class GameEvent {
  final DateTime timestamp;
  final String eventData;

  GameEvent(this.timestamp, this.eventData);
}

class GameEventPlaybackService {
  late final StreamController<GameEventData> _eventsController;

  final List<GameEventData> _events;
  bool _isPaused = false;
  DateTime? _lastEventTime;
  Timer? _timer;
  int _currentIndex = 0;

  Stream<GameEventData> get eventsStream => _eventsController.stream;
  List<GameEventData> get events => _events;
  DateTime get lastEventTime => _lastEventTime!;

  GameEventPlaybackService(this._events) {
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
    _isPaused = true;
    _timer?.cancel();
  }

  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    _playbackEvents();
  }

  void restart() {
    pause();
    _currentIndex = 0;
    _lastEventTime = null;
    _playbackEvents();
  }

  void _playbackEvents() async {
    if (_events.isEmpty) return;

    for (int i = _currentIndex; i < _events.length && !_isPaused; i++) {
      final event = _events[i];
      final DateTime previousEventTime =
          i == 0 ? event.timestamp : _events[i - 1].timestamp;
      final durationSinceLastEvent =
          event.timestamp.difference(previousEventTime).inMilliseconds;

      if (durationSinceLastEvent > 0) {
        await Future.delayed(Duration(milliseconds: durationSinceLastEvent),
            () {
          if (_isPaused) return;
          _eventsController.sink.add(event);
          _lastEventTime = event.timestamp;
          _currentIndex = i;
        });
      } else {
        if (_isPaused) break;
        _eventsController.sink.add(event);
        _lastEventTime = event.timestamp;
        _currentIndex = i;
      }
    }
  }

  void _stopPlayback() {
    _timer?.cancel();
    _eventsController.sink.close();
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
