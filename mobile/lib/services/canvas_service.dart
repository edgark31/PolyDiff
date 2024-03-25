// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile/models/game.dart';

// /* 
// *  Invoker : Holds a command and can invoke the command's execute() 
// *  method to perform the action. The Invoker can be thought of as a remote control with buttons; 
// *  each button triggers a specific command, but the remote doesn't perform the action itself. 
// */

// /*
// *  Command : Declares an interface for executing an operation.
// *  Invoker Receives the Request: The action is captured by an Invoker (e.g., a button in a UI), which holds a Command object.
// *  Receiver : The Receiver knows how to perform the operation associated with a request.
// */

// class CanvasService extends ChangeNotifier {
//   bool isCheatMode = false;
//   Path? cheatBlinkingDifference;
//   Paint blinkingColor = Paint()..color = Colors.transparent; // Default color
//   List<Coordinate> differences;

//   CanvasService({required this.differences});

//   void handleClickEvent(Offset offset) {
//     Coordinate? foundDifference = differences.firstWhereOrNull(
//       (difference) => difference.contains(offset),
//     );

//     if (foundDifference != null) {
//       print("Difference found");
//       differences.remove(foundDifference);
//       print("Difference removed: $foundDifference");
//       // If cheat mode is not active, blink in normal color
//       if (!isCheatMode) {
//         startBlinking([foundDifference]);
//       }
//       notifyListeners();
//     } else {
//       print("Difference not found");
//     }
//     print("Click event handled");
//   }

//   void initPath(List<Coordinate> coords) {
//     final path = Path();
//     for (var coord in coords) {
//       // Assuming coordinates are points; you might adjust for area/shape
//       path.addRect(Rect.fromLTWH(
//         coord.x.toDouble(),
//         coord.y.toDouble(),
//         1,
//         1,
//       ));
//     }
//     cheatBlinkingDifference = path;
//   }

//   Future<void> toggleCheatMode(List<Coordinate> coords) async {
//     isCheatMode = !isCheatMode;
//     if (isCheatMode) {
//       initPath(coords); // Initialize path with cheat coordinates
//       await startCheatBlinking();
//     } else {
//       cheatBlinkingDifference = null;
//       notifyListeners();
//     }
//   }

//   Future<void> startBlinking(List<Coordinate> coords) async {
//     initPath(coords);
//     final Path blinkingPath = cheatBlinkingDifference!;
//     const int timeToBlinkMs = 100;

//     blinkingColor.color = Colors.green;
//     for (int i = 0; i < 3; i++) {
//       await showBlinkingDifference(blinkingPath, timeToBlinkMs);
//       await hideBlinkingDifference(timeToBlinkMs);
//     }
//     blinkingColor.color = Colors.transparent; // Reset color
//     cheatBlinkingDifference = null;
//     notifyListeners();
//   }

//   Future<void> startCheatBlinking() async {
//     if (cheatBlinkingDifference == null) return;
//     const int timeToBlinkMs = 150;
//     const int cheatModeWaitMs = 250;

//     blinkingColor.color = Colors.red;
//     while (isCheatMode) {
//       await showBlinkingDifference(cheatBlinkingDifference!, timeToBlinkMs);
//       await hideBlinkingDifference(cheatModeWaitMs);
//     }
//     blinkingColor.color = Colors.transparent; // Reset color
//     cheatBlinkingDifference = null;
//     notifyListeners();
//   }

//   Future<void> showBlinkingDifference(
//       Path difference, int waitingTimeMs) async {
//     cheatBlinkingDifference = difference;
//     notifyListeners();
//     await Future.delayed(Duration(milliseconds: waitingTimeMs));
//   }

//   Future<void> hideBlinkingDifference(int waitingTimeMs) async {
//     cheatBlinkingDifference = null;
//     notifyListeners();
//     await Future.delayed(Duration(milliseconds: waitingTimeMs));
//   }
// }
