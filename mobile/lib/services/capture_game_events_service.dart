import 'dart:async';

import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';

class CaptureGameEventsService {
  final _replayEventsController = StreamController<ReplayEvent>.broadcast();

  Stream<ReplayEvent> get replayEventsStream => _replayEventsController.stream;

  void saveReplayEvent(GameEvents action, Coordinate data) {
    final replayEvent = ReplayEvent(
      action: action,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: data,
    );
    _replayEventsController.add(replayEvent);
  }

  void dispose() {
    _replayEventsController.close();
  }
}
