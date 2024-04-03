import 'package:flutter/material.dart';

class TimelineWidget extends StatefulWidget {
  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  // You might want to use a better data structure to represent the timeline
  bool _isPlaying = true;
  double _currentTime = 0.0;
  double number = 360;
  int _selectedSpeed = 1;

  void _triggerPlay() {
    if (_isPlaying) {
      _onPause();
    } else {
      _onPlay();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _onPlay() {
    // Implement play functionality
  }

  void _onPause() {
    // Implement pause functionality
  }

  void _restart() {
    // Implement forward functionality
  }
  void _goHome() {
    // Implement forward functionality
  }

  void _changeSpeed(int speed) {
    setState(() {
      _selectedSpeed = speed;
    });
    print('Changing speed to $_selectedSpeed');
    // Implement speed change functionality
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: _goHome,
            ),
            IconButton(
              icon: Icon(Icons.replay_outlined),
              onPressed: _restart,
            ),
            IconButton(
              icon: _isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
              onPressed: _triggerPlay,
            ),
          ],
        ),
        Expanded(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          child: Slider(
            value: _currentTime,
            min: 0.0,
            max: number,
            divisions: number.floor(),
            label: _currentTime.round().toString(),
            onChanged: (double newValue) {
              setState(() {
                _currentTime = newValue;
              });
            },
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int speed in [1, 2, 4]) _buildSpeedRadioButton(speed)
          ],
        ),
      ],
    );
  }

  Widget _buildSpeedRadioButton(int speed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(
          value: speed,
          groupValue: _selectedSpeed,
          onChanged: (int? value) {
            if (value != null) {
              _changeSpeed(value);
            }
          },
        ),
        Text('${speed}x'),
      ],
    );
  }
}
