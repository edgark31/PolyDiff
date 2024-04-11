import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'replay_service.dart';

class ReplayTimelinePlayer extends StatefulWidget {
  @override
  State<ReplayTimelinePlayer> createState() => _ReplayTimelinePlayerState();
}

class _ReplayTimelinePlayerState extends State<ReplayTimelinePlayer> {
  double _currentSliderValue = 0; // Slider position

  @override
  Widget build(BuildContext context) {
    final replayService = context.watch<ReplayService>();

    int totalDurationMs =
        replayService.record.duration; // Duration in milliseconds

    return Column(
      children: [
        Slider(
          min: 0,
          max: totalDurationMs.toDouble(),
          value: replayService.replayTimer.toDouble(),
          divisions: 10,
          label: '${(replayService.replayTimer / 1000).round()} seconds',
          onChanged: (value) {
            setState(() {
              replayService.replayTimer = value.toInt();
            });
            replayService.fallBack((replayService.replayTimer / 1000).round());
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed:
                  replayService.isReplaying ? null : replayService.resumeReplay,
            ),
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: !replayService.isReplaying
                  ? null
                  : () => replayService.pauseReplay,
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _currentSliderValue = 0; // Reset slider
                });
                replayService.fallBack((_currentSliderValue).round());
                replayService.restartReplay; // reset and start the replay
              },
            ),
          ],
        ),
      ],
    );
  }
}
