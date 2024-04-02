import 'package:flutter/material.dart';

enum CanvasActions {
  removeDifference,
  blinkDifference,
}

extension CanvasActionsExtension on CanvasActions {
  String get value {
    switch (this) {
      case CanvasActions.removeDifference:
        return "remove difference";
      case CanvasActions.blinkDifference:
        return "Blink difference";
    }
  }
}

// Returns a set of actions
abstract class Receiver {
  Set<String> get actions;
}

// Encapsulates canvas commands as objects
abstract class Command {
  Receiver receiver;
  String name = "";

  Command(this.receiver);

  @override
  String toString() => name;

  void execute();
}

class Invoker {
  List<String> commandHistoryList = [];

  void execute(Command command) {
    command.execute();
    commandHistoryList
        .add("[${DateTime.now()}] Executed: ${command.toString()}");
  }

  @override
  String toString() => commandHistoryList.fold(
      "", (previousEvents, event) => "$previousEvents\n$event");
}

class RemoveDifferenceCommand extends Command {
  Offset difference;
  RemoveDifferenceCommand(CanvasReceiver super.receiver, this.difference) {
    name = "Remove difference";
  }

  @override
  void execute() {
    (receiver as CanvasReceiver).removeDifference(difference);
  }
}

class BlinkDifferenceCommand extends Command {
  Offset difference;
  BlinkDifferenceCommand(CanvasReceiver super.receiver, this.difference) {
    name = "Blink difference";
  }

  @override
  void execute() {
    (receiver as CanvasReceiver).blinkDifference(difference);
  }
}

class CanvasDifference {
  Invoker _difference = Invoker();
  CanvasReceiver canvas;

  CanvasDifference(this.canvas);

  void perform(CanvasActions action, Offset difference) {
    Command command;
    switch (action) {
      case CanvasActions.removeDifference:
        command = RemoveDifferenceCommand(canvas, difference);

      case CanvasActions.blinkDifference:
        command = BlinkDifferenceCommand(canvas, difference);

      default:
        print("Action not recognized");
        return;
    }
    _difference.execute(command);
  }
}

class CanvasReceiver extends ChangeNotifier implements Receiver {
  List<Offset> differences = [
    Offset(100, 100),
    Offset(200, 150),
    Offset(250, 250)
  ];

  @override
  Set<String> get actions => {"remove difference", "blink difference"};

  void removeDifference(Offset difference) {
    differences.remove(difference);
    print(differences);
    notifyListeners();
    print("Difference removed at $difference");
  }

  void blinkDifference(Offset difference) {
    // Implementation of blinking logic (this is just a placeholder)
    print("Blinking difference at $difference");
  }
}
