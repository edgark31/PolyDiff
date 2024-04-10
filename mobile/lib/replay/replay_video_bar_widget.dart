import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'replay_service.dart'; // Ensure correct import path

class ReplayTimelinePlayer extends StatefulWidget {
  @override
  _ReplayTimelinePlayerState createState() => _ReplayTimelinePlayerState();
}

class _ReplayTimelinePlayerState extends State<ReplayTimelinePlayer> {
  double _currentSliderValue = 0; // Slider position

  @override
  Widget build(BuildContext context) {
    final replayService = Provider.of<ReplayService>(context);
    // Assuming 'duration' is in seconds, and converting it to milliseconds for the slider
    int totalDurationMs =
        replayService.record.duration; // Duration is already in milliseconds

    return Column(
      children: [
        Slider(
          min: 0,
          max: totalDurationMs.toDouble(),
          value: _currentSliderValue,
          divisions: 10,
          label: '${(_currentSliderValue / 1000).round()} seconds',
          onChanged: (value) {
            setState(() {
              _currentSliderValue = value;
            });
            replayService.fallBack((_currentSliderValue / 1000).round());
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: replayService.isPlaying ? null : replayService.resume,
            ),
            IconButton(
              icon: Icon(Icons.pause),
              onPressed:
                  !replayService.isPlaying ? null : () => replayService.pause(),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _currentSliderValue = 0; // Reset slider
                });
                replayService
                    .restart(); // This should reset and start the replay
              },
            ),
          ],
        ),
      ],
    );
  }
}
