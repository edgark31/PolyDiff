import 'package:flutter/material.dart';
import 'package:mobile/models/replay_model.dart';
import 'package:mobile/services/capture_game_events_service.dart';
import 'package:provider/provider.dart';

// TODO: If we want to take a snapshot of the canvas state, we can use this widget
class GameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final captureService = Provider.of<CaptureGameEventsService>(context);

    return StreamBuilder<ReplayGameEvent>(
      stream: captureService.replayEventsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // TODO : Handle your replay event
        }
        return Container(); // TODO : Replace with game UI here
      },
    );
  }
}
