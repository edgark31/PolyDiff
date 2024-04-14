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
  double _selectedSpeed = SPEED_X1;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    // Subscribe to the event stream
    if (widget.playbackService.events.isNotEmpty) {
      _eventsSubscription =
          widget.playbackService.eventsStream.listen((GameEventData event) {
        updateSliderValue(event);
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

  void updateSliderValue(GameEventData event) {
    int eventIndex = widget.playbackService.events.indexOf(event);
    if (eventIndex != -1 && mounted) {
      setState(() {
        _sliderValue = calculateSpeedAdjustedSliderValue(eventIndex);
        _currentEvent = event.gameEvent;
      });
    }
  }

  double calculateSpeedAdjustedSliderValue(int eventIndex) {
    double baseValue =
        eventIndex / (widget.playbackService.events.length - 1).toDouble();
    // Adjust baseValue based on the current playback speed.
    double speedAdjustment = widget.playbackService.speed / SPEED_X1;
    return baseValue * speedAdjustment;
  }

  void _triggerPlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      print("Resuming");
      widget.playbackService.resume();
    } else {
      print("Pausing");
      widget.playbackService.pause();
    }
  }

  void _goHome() {
    // TODO : Implement home functionality
    // Implement forward functionality
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
              icon: Icon(Icons.home),
              onPressed: _goHome,
            ),
            IconButton(
              icon: _isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
              onPressed: _triggerPlay,
            ),
            // Restart button
            IconButton(
              icon: Icon(Icons.restart_alt),
              onPressed: () {
                widget.playbackService.restart();
                // Reset the slider to the start
                setState(() {
                  _isPlaying = true;
                  _sliderValue = 0;
                });
              },
            ),
            // Speed buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (double speed in [SPEED_X1, SPEED_X2, SPEED_X4])
                  _buildSpeedRadioButton(speed)
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeedRadioButton(double speed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<double>(
          value: speed,
          groupValue: _selectedSpeed,
          onChanged: (double? value) {
            if (value != null) {
              setState(() {
                _selectedSpeed = value;
                widget.playbackService.setSpeed(value);
              });
            }
          },
        ),
        Text('${speed}x'),
      ],
    );
  }
}
