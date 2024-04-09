import 'dart:async';

import 'package:mobile/models/game_record_model.dart';

abstract class ReplayPlayer {
  void start([int delay = 0]);
  void pause();
  void resume();
  void cancel();
}

class ReplayInterval implements ReplayPlayer {
  bool _isReplaying = false;
  late int _remainingTime;
  int _currentReplayIndex = 0;
  DateTime? _pauseTime;

  final List<GameEventData> _replayEvents;
  final void Function(GameEventData) _callback;
  final int Function(GameEventData) _getNextInterval;

  Timer? _timer;

  ReplayInterval(this._replayEvents, this._callback, this._getNextInterval);

  @override
  void start([int delay = 0]) {
    if (!_isReplaying || _currentReplayIndex >= _replayEvents.length) {
      _isReplaying = true;
      _processEvent(delay);
    }
  }

  void _processEvent([int delay = 0]) {
    if (_currentReplayIndex < _replayEvents.length) {
      _remainingTime = delay == 0
          ? _getNextInterval(_replayEvents[_currentReplayIndex])
          : delay;

      if (delay == 0) {
        _callback(_replayEvents[_currentReplayIndex]);
        _currentReplayIndex++;
      }

      _timer?.cancel(); // Ensure no previous timer is running
      _timer = Timer(Duration(milliseconds: _remainingTime), _handleTimeout);
    } else {
      cancel(); // No more events to process
    }
  }

  @override
  void pause() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      _pauseTime = DateTime.now(); // Record pause time for accurate resume
    }
  }

  @override
  void resume() {
    if (!_isReplaying || _pauseTime == null) return;

    var now = DateTime.now();
    var elapsed = now.difference(_pauseTime!).inMilliseconds;
    _remainingTime = (_remainingTime - elapsed).clamp(0, _remainingTime);
    _pauseTime = null; // Clear pause time

    _processEvent(_remainingTime);
  }

  @override
  void cancel() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _isReplaying = false;
    _currentReplayIndex = 0; // Reset index for potential future replays
    _pauseTime = null; // Ensure pause time is reset
  }

  void _handleTimeout() {
    if (_currentReplayIndex < _replayEvents.length) {
      _callback(_replayEvents[_currentReplayIndex]);
      _currentReplayIndex++;
      _processEvent();
    } else {
      cancel();
    }
  }
}
