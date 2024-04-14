import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/providers/game_record_provider.dart';

class GameEventPlaybackService extends ChangeNotifier {
  final GameRecordProvider _gameRecordProvider = Get.find();
  late final StreamController<GameEventData> _eventsController;

  bool _isPaused = false;
  bool _isUserInteraction = false;

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
    print("Playback paused.");
    _isPaused = true;
    _timer?.cancel();
    _isUserInteraction = true;
  }

  void resume() {
    if (!_isPaused) return;
    _isUserInteraction = false;
    _isPaused = false;

    print("Resuming playback.");
    _playbackEvents();
  }

  void restart() {
    _isUserInteraction = true;
    pause();
    _eventsController.addStream(Stream.fromIterable([]));

    _currentIndex = 0;
    _speed = SPEED_X1;
    _lastEventTime = events.first.timestamp;
    _isPaused = false;

    Future.delayed(Duration.zero, () {
      _playbackEvents();
    }).then((_) {
      _isUserInteraction = false;
    });
  }

  void setSpeed(double speed) {
    _speed = speed;
    if (!_isPaused) {
      pause();
      resume();
    }
  }

  void _playbackEvents() async {
    if (events.isEmpty || _isPaused) {
      print("No events to play or playback is paused.");
      return;
    }

    for (int i = _currentIndex; i < events.length && !_isPaused; i++) {
      final GameEventData event = events[i];
      final DateTime previousEventTime =
          i == 0 ? event.timestamp : events[i - 1].timestamp;
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

      if (!isUserInteraction) {
        _eventsController.sink.add(event);
      }
      print("Event added to stream: ${event.gameEvent}");

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
    _isUserInteraction = true;

    pause();
    _currentIndex = eventIndex;

    Future.delayed(Duration(milliseconds: 100), () {
      resume();
      _isUserInteraction = false;
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
