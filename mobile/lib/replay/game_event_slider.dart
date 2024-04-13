import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/replay/game_event_playback_manager.dart';
import 'package:mobile/replay/game_events_services.dart';

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
  Timer? _debounceTimer;
  double _sliderValue = 0;
  late StreamSubscription<GameEventData> _eventsSubscription;
  String _currentEvent = "";

  @override
  void initState() {
    super.initState();
    // Subscribe to the event stream
    if (widget.playbackService.events.isNotEmpty) {
      _eventsSubscription =
          widget.playbackService.eventsStream.listen((GameEventData event) {
        int eventIndex = widget.playbackService.events.indexOf(event);
        if (eventIndex != -1 && mounted) {
          setState(() {
            _sliderValue = eventIndex /
                (widget.playbackService.events.length - 1).toDouble();
            _currentEvent = event.gameEvent;
          });
        }
      }, onError: (error) {
        print("Error occurred in event subscription: $error");
      }, onDone: () {
        print("Event stream is closed");
      });
    }
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  void _onSliderChanged(double newValue) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _sliderValue = newValue;
        int eventIndex =
            (_sliderValue * (widget.playbackService.events.length - 1)).round();
        widget.playbackService.seekToEvent(eventIndex);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Assuming the slider value ranges from 0 to 1, normalized
    return Column(
      children: [
        Slider(
          min: 0,
          max: 1,
          value: _sliderValue,
          divisions: widget.playbackService.events.length - 1,
          onChanged: _onSliderChanged,
        ),
        // Display the gameEvent of the selected event
        Text("Current Event: $_currentEvent"),
        // This displays the slider's value; it's optional and can be removed if not needed
        Text("Slider Value: ${_sliderValue.toStringAsFixed(2)}"),

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
            // Speed buttons
            IconButton(
              icon: Text('1x'),
              onPressed: () {
                widget.playbackService.setSpeed(SPEED_X1);
              },
            ),
            IconButton(
              icon: Text('2x'),
              onPressed: () {
                widget.playbackService.setSpeed(SPEED_X2);
              },
            ),
            IconButton(
              icon: Text('4x'),
              onPressed: () {
                widget.playbackService.setSpeed(SPEED_X4);
              },
            ),
          ],
        ),
      ],
    );
  }
}
