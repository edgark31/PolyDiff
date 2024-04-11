import 'dart:async';

import 'package:mobile/models/game_record_model.dart';

List<GameEventData> getTestGameEventsData() {
  return [
    GameEventData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(1712853581979),
      gameEvent: "StartGame",
      time: null,
    ),
    GameEventData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(1712853583064),
        gameEvent: "TimerUpdate",
        time: 59,
        modified:
            "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII="),
    GameEventData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(1712853584063),
      gameEvent: "TimerUpdate",
      time: 58,
    ),
    GameEventData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(1712853585064),
      gameEvent: "TimerUpdate",
      time: 57,
    ),
    // Example of a "NotFound" event, indicating an unsuccessful attempt to find a difference
    GameEventData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(1712853586065),
      gameEvent: "NotFound",
      time: 56,
    ),
    // Example of a "Found" event, indicating a successful discovery of a difference
    GameEventData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(1712853587066),
      gameEvent: "Found",
      time: 55,
    ),
    // Example of a "CheatActivated" event, indicating the activation of a cheat mode
    GameEventData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(1712853588067),
      gameEvent: "CheatActivated",
      time: 54,
    ),
    // More TimerUpdate events can be added as needed
    GameEventData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(1712853589068),
      gameEvent: "TimerUpdate",
      time: 53,
    ),
    // Additional events...
  ];
}

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
    _lastEventTime = null;
    _playbackEvents();
  }

  void _playbackEvents() async {
    if (_events.isEmpty) return;

    for (int i = 0; i < _events.length && !_isPaused; i++) {
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
        });
      } else {
        if (_isPaused) break;
        _eventsController.sink.add(event);
        _lastEventTime = event.timestamp;
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
