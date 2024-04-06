import 'package:flutter/material.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:provider/provider.dart';

class GameRecordDetails extends StatefulWidget {
  const GameRecordDetails({super.key});

  @override
  State<GameRecordDetails> createState() => _GameRecordDetailsState();
}

class _GameRecordDetailsState extends State<GameRecordDetails> {
  @override
  Widget build(BuildContext context) {
    final GameRecordProvider gameRecordProvider =
        Provider.of<GameRecordProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Game Details"), // Optionally, include an AppBar for better navigation/UI
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Game: ${gameRecordProvider.gameRecord.game.name}"),
            Text(
              "Date: ${gameRecordProvider.gameRecord.date})",
            ),
            Text("Duration: ${gameRecordProvider.gameRecord.duration} seconds"),
            Text(
                "Cheat Enabled: ${gameRecordProvider.gameRecord.isCheatEnabled ? "Yes" : "No"}"),
            const Divider(),
            Text("Players:"),
            ...gameRecordProvider.gameRecord.players
                .map((player) => Text(player.name!))
                .toList(), // Ensure .toList() is called
            const Divider(),
            Text("Game Events:"),
            ...gameRecordProvider.gameRecord.gameEvents
                .map((event) => ListTile(
                      title: Text(event.username ?? "Unknown"),
                      subtitle: Text(event.gameEvent),
                      trailing: event.timestamp != null
                          ? Text(DateTime.fromMillisecondsSinceEpoch(
                                  event.timestamp!)
                              .toString())
                          : null,
                    ))
                .toList(),
            CustomButton(
                text: 'sauvegarder la reprise',
                press: () {
                  gameRecordProvider
                      .addAccountIdByDate(gameRecordProvider.gameRecord.date);
                }) // Ensure .toList() is called
          ],
        ),
      ),
    );
  }
}
