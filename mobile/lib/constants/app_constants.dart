// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:mobile/models/account.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/game_record_model.dart';

// Background image paths
const String EMPTY_BACKGROUND_PATH = 'assets/images/empty_background.jpg';
const String EMPTY_BACKGROUND_PATH_DARK =
    'assets/images/empty_background_dark.png';
const String MENU_BACKGROUND_PATH = 'assets/images/menu_background.jpg';
const String MENU_BACKGROUND_PATH_DARK =
    'assets/images/menu_background_dark.png';
const String SELECTION_BACKGROUND_PATH =
    'assets/images/selection_background.jpg';
const String SELECTION_BACKGROUND_PATH_DARK =
    'assets/images/selection_background_dark.jpg';
const String GAME_BACKGROUND_PATH = 'assets/images/game_background.jpg';
const String GAME_BACKGROUND_PATH_DARK =
    'assets/images/game_background_dark.png';
const String LIMITED_TIME_BACKGROUND_PATH =
    'assets/images/LimitedTimeBackground.jpg';
const String LIMITED_TIME_BACKGROUND_PATH_DARK =
    'assets/images/LimitedTimeBackground_dark.jpg';

// Default sounds

List<Sound> ERROR_SOUND_LIST = [
  Sound(name: "NOT GOOD 1", path: "assets/sound/error1.mp3"),
  Sound(name: "NOT GOOD 2", path: "assets/sound/error2.mp3"),
  Sound(name: "NOT GOOD 3", path: "assets/sound/error3.mp3"),
];

// Default Correct sounds
List<Sound> CORRECT_SOUND_LIST = [
  Sound(name: "TOO GOOD 1", path: "assets/sound/correct1.mp3"),
  Sound(name: "TOO GOOD 2", path: "assets/sound/correct2.mp3"),
  Sound(name: "TOO GOOD 3", path: "assets/sound/correct3.mp3"),
];

// Default Game Record
GameRecord DEFAULT_GAME_RECORD = GameRecord(
  game: Game.initial(),
  players: [],
  accountIds: [],
  date: DateTime.now().toUtc().toString(),
  startTime: 0,
  endTime: 0,
  duration: 0,
  isCheatEnabled: false,
  timeLimit: 0,
  gameEvents: [],
);

// Replay speeds
const int SPEED_X1 = 1;
const int SPEED_X2 = 2;
const int SPEED_X4 = 4;

const REPLAY_SPEEDS = [SPEED_X1, SPEED_X2, SPEED_X4];
const int REPLAY_LIMITER = 1000;

// Colors
const kDark = Colors.black;
const kLight = Color(0xFFFFFFFF);

const kLime = Color.fromRGBO(158, 157, 36, 1);

const kGreen = Color(0xFF43A047);
const kLightGreen = Color.fromRGBO(85, 139, 47, 1);
const kMidGreen = Color.fromRGBO(123, 142, 5, 1);
const kDarkGreen = Color.fromARGB(255, 4, 41, 7);

const Color kLightOrange = Color.fromRGBO(245, 124, 0, 1);
const Color kMidOrange = Color.fromRGBO(239, 108, 0, 1);
const Color kDarkOrange = Color.fromRGBO(230, 81, 0, 1);

const Color kMidPink = Color.fromRGBO(255, 105, 180, 1);

// Replay Speed
const int SPEED_X1 = 1;
const int SPEED_X2 = 2;
const int SPEED_X4 = 4;
