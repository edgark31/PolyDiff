import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/replay/game_event_playback_manager.dart';
import 'package:mobile/replay/game_events_services.dart';
import 'package:mobile/replay/replay_images_provider.dart';

class GameEventSlider extends StatefulWidget {
  final GameEventPlaybackService playbackService;
  final GameEventPlaybackManager playbackManager;
  final ReplayImagesProvider replayImagesProvider;

  GameEventSlider({
    super.key,
    required this.playbackService,
    required this.playbackManager,
    required this.replayImagesProvider,
  });

  @override
  State<GameEventSlider> createState() => _GameEventSliderState();
}

class _GameEventSliderState extends State<GameEventSlider> {
  double _sliderValue = 0;
  late StreamSubscription<GameEventData> _eventsSubscription;
  String _currentEvent = "";
  String _currentTime = "";

  @override
  void initState() {
    super.initState();
    // Subscribe to the event stream
    widget.playbackService.eventsStream.listen((GameEventData event) {
      int eventIndex = widget.playbackService.events.indexOf(event);
      double newSliderValue =
          eventIndex / (widget.playbackService.events.length - 1).toDouble();

      if (mounted) {
        setState(() {
          if (eventIndex == 0) {
            _sliderValue = 0; // Reset slider for the first event after restart.
          } else {
            _sliderValue = newSliderValue;
          }
          _currentEvent = event.gameEvent;
          _currentTime = event.time.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

// To display the current event's time

  @override
  Widget build(BuildContext context) {
    // Assuming the slider value ranges from 0 to 1, normalized
    return Column(
      children: [
        Slider(
          min: 0,
          max: 1, // Slider position is normalized between 0 and 1
          value: _sliderValue,
          divisions: widget.playbackService.events.length - 1,
          onChanged: (newValue) {
            setState(() {
              _sliderValue = newValue;
              // Calculate the event index based on the new slider value
              int eventIndex =
                  (_sliderValue * (widget.playbackService.events.length - 1))
                      .round();
              int eventIndexToSeek = widget.playbackService
                  .calculateEventIndexFromSliderPosition(
                      _sliderValue, widget.playbackService.events);
              // Check if eventIndex falls within the valid range before proceeding
              if (eventIndex >= 0 &&
                  eventIndex < widget.playbackService.events.length) {
                _currentEvent =
                    widget.playbackService.events[eventIndex].gameEvent;
                _currentTime =
                    widget.playbackService.events[eventIndex].time!.toString();
                // Inform the playback manager to handle the event at this index
                widget.playbackManager.seekToEvent(
                    eventIndexToSeek, widget.playbackService.events);
              }
            });
          },
        ),
        // Display the gameEvent of the selected event
        Text("Current Event: $_currentEvent"),
        // This displays the slider's value; it's optional and can be removed if not needed
        Text("Slider Value: ${_sliderValue.toStringAsFixed(2)}"),
        // Display the current time associated with the game event, if any
        Text("Current time: ${_currentTime.toString()}"),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                widget.playbackService.resume();
              },
            ),
            // Restart button
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: () {
                widget.playbackService.pause();
              },
            ),
            // Restart button
            IconButton(
              icon: Icon(Icons.restart_alt),
              onPressed: () {
                widget.playbackService.restart();
                // Reset the slider to the start
                setState(() {
                  _sliderValue = 0;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
