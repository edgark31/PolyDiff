import 'dart:async';

import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';

class CaptureGameEventsService {
  final _replayEventsController = StreamController<ReplayGameEvent>.broadcast();

  Stream<ReplayGameEvent> get replayEventsStream =>
      _replayEventsController.stream;

  void saveReplayEvent(GameEvent action, Map<String, dynamic> data) {
    final replayEvent = ReplayGameEvent(
      action: action,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: data,
    );
    print('about to add replay event: $data');
    _replayEventsController.add(replayEvent);
  }

  void dispose() {
    _replayEventsController.close();
  }
}
