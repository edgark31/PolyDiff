import 'package:flutter/material.dart';
import 'package:mobile/models/game_record_model.dart';

class GameRecordDetails extends StatefulWidget {
  final GameRecord gameRecord;

  const GameRecordDetails({super.key, required this.gameRecord});

  @override
  State<GameRecordDetails> createState() => _GameRecordDetailsState();
}

class _GameRecordDetailsState extends State<GameRecordDetails> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Game: ${widget.gameRecord.game.name}"),
          Text("Difficulty: ${widget.gameRecord.game.difficulty}"),
          Text(
            "Date: ${widget.gameRecord.date})",
          ),
          Text("Duration: ${widget.gameRecord.duration} seconds"),
          Text(
              "Cheat Enabled: ${widget.gameRecord.isCheatEnabled ? "Yes" : "No"}"),
          const Divider(),
          Text("Players:"),
          ...widget.gameRecord.players.map((player) => Text(player.name!)),
          const Divider(),
          Text("Game Events:"),
          ...widget.gameRecord.gameEvents.map((event) => ListTile(
                title: Text(event.username),
                subtitle: Text(event.gameEvent),
                trailing: event.timestamp != null
                    ? Text(DateTime.fromMillisecondsSinceEpoch(event.timestamp!)
                        .toString())
                    : null,
              )),
        ],
      ),
    );
  }
}
