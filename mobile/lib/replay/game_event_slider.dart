import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/replay/game_event_playback_manager.dart';
import 'package:mobile/replay/game_events_services.dart';
import 'package:mobile/services/services.dart';

class GameEventSlider extends StatefulWidget {
  final GameEventPlaybackService playbackService;
  final GameEventPlaybackManager playbackManager;

  GameEventSlider({
    super.key,
    required this.playbackService,
    required this.playbackManager,
  });

  @override
  State<GameEventSlider> createState() => _GameEventSliderState();
}

class _GameEventSliderState extends State<GameEventSlider> {
  double _sliderValue = 0;
  late StreamSubscription<GameEventData> _eventsSubscription;
  String _currentEvent = "";
  String _currentTime = "";
  String? _currentImage = "";

  @override
  void initState() {
    super.initState();
    // Subscribe to the event stream
    widget.playbackService.eventsStream.listen((GameEventData event) {
      // Calculate the new slider value based on the event index
      int eventIndex = widget.playbackService.events.indexOf(event);
      double newSliderValue =
          eventIndex / (widget.playbackService.events.length - 1).toDouble();

      if (mounted) {
        setState(() {
          // Check if we're dealing with the first event after a restart and adjust if necessary.
          // This could be refined based on your application's logic and event handling.
          if (eventIndex == 0) {
            _sliderValue = 0; // Reset slider for the first event after restart.
          } else {
            _sliderValue = newSliderValue;
          }
          _currentEvent = event.gameEvent;
          _currentTime = event.time.toString();
          _currentImage = event.modified ?? "";
        });
      }
    });
  }

  @override
  void dispose() {
    // Make sure to cancel your event stream subscription when the widget is disposed
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

        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.memory(
                ImageConverterService.uint8listFromBase64String(
                    _currentImage ?? ""),
              ),
              SizedBox(height: 10),
            ],
          ),
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
                widget.playbackService.resume(); // Use the play method
              },
            ),
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: () {
                widget.playbackService.pause(); // Use the pause method
              },
            ),
            // Restart button
            IconButton(
              icon: Icon(Icons.restart_alt),
              onPressed: () {
                widget.playbackService.restart();
                // Also, reset the slider to the start
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
