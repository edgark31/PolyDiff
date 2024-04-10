import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/models/game_record_model.dart';

abstract class ReplayPlayer {
  void start([int delay = 0]);
  void pause();
  void resume();
  void cancel();
}

class ReplayInterval extends ChangeNotifier implements ReplayPlayer {
  bool _isReplaying = false;
  late int _remainingTime;
  int _currentIndex = 0;
  DateTime? _pauseTime;

  bool get isReplaying => _isReplaying;
  int get remainingTime => _remainingTime;
  int get currentIndex => _currentIndex;
  DateTime? get pauseTime => _pauseTime;
  Timer? get timer => _timer;

  final List<GameEventData> _replayEvents;
  final void Function(GameEventData) _callback;
  final int Function(GameEventData) _getNextInterval;

  Timer? _timer;

  ReplayInterval(this._replayEvents, this._callback, this._getNextInterval);

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  @override
  void start([int delay = 0]) {
    if (!_isReplaying || _currentIndex >= _replayEvents.length) {
      _isReplaying = true;
      notifyListeners();
      _processEvent(delay);
    }
  }

  void _processEvent([int delay = 0]) {
    print("currentReplayIndex: $_currentIndex");
    if (_currentIndex < _replayEvents.length) {
      _remainingTime =
          delay == 0 ? _getNextInterval(_replayEvents[_currentIndex]) : delay;

      if (delay == 0) {
        _callback(_replayEvents[_currentIndex]);
        _currentIndex++;
      }

      _timer?.cancel();
      _timer = Timer(Duration(milliseconds: _remainingTime), _handleTimeout);
      notifyListeners();
    } else {
      cancel();
    }
  }

  @override
  void pause() {
    if (_timer?.isActive ?? false) {
      _isReplaying = false;

      _timer?.cancel();

      _pauseTime = DateTime.now();
      notifyListeners();
    }
  }

  @override
  void resume() {
    if (!_isReplaying || _pauseTime == null) return;

    DateTime now = DateTime.now();
    var elapsed = now.difference(_pauseTime!).inMilliseconds;
    _remainingTime = (_remainingTime - elapsed).clamp(0, _remainingTime);
    _pauseTime = null;

    _processEvent(_remainingTime);
  }

  @override
  void cancel() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _isReplaying = false;
    _currentIndex = 0;
    _pauseTime = null;
  }

  void _handleTimeout() {
    if (_currentIndex < _replayEvents.length) {
      _callback(_replayEvents[_currentIndex]);
      _currentIndex++;
      _processEvent();
    } else {
      cancel();
    }
  }
}
