import 'dart:async';

import 'package:flutter/material.dart';

class TimelineWidget extends StatefulWidget {
  final int replayDuration;
  const TimelineWidget({super.key, required this.replayDuration});

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  bool _isPlaying = true;
  double _currentTime = 0.0;
  double gameLength = 0.0;

  int _selectedSpeed = 1;
  Timer? _timer;

  void _triggerPlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _startReplay();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    gameLength = widget.replayDuration / 1000; // covert to seconds

    if (_isPlaying) {
      _startReplay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startReplay() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        _currentTime += _selectedSpeed / 10;
        if (_currentTime >= gameLength) {
          _currentTime = gameLength;
          _timer?.cancel();
          _isPlaying = false;
        }
      });
    });
  }

  void _restart() {
    setState(() {
      _currentTime = 0.0;
      _isPlaying = true;
    });
    _timer?.cancel();
    if (_isPlaying) {
      _startReplay();
    }
  }

  void _goHome() {
    // Implement forward functionality
  }

  void _changeSpeed(int speed) {
    setState(() {
      _selectedSpeed = speed;
      if (_isPlaying) {
        _timer?.cancel();
        _startReplay();
      }
    });
    print('Changing speed to $_selectedSpeed');
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        "${(_currentTime.floor() ~/ 60).toString().padLeft(2, '0')}:${(_currentTime.floor() % 60).toString().padLeft(2, '0')}";
    return Row(
      children: [
        SizedBox(width: 60),
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
        SizedBox(width: 15),
        Expanded(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          child: Slider(
            value: _currentTime,
            min: 0.0,
            max: gameLength,
            divisions: gameLength.floor(),
            label: formattedTime,
            onChanged: (double newValue) {
              setState(() {
                _currentTime = newValue;
              });
            },
          ),
        ),
        SizedBox(width: 15),
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(width: 15),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int speed in [1, 2, 4]) _buildSpeedRadioButton(speed)
          ],
        ),
        SizedBox(width: 60),
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
