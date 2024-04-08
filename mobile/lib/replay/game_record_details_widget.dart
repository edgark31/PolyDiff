import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/services/image_converter_service.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:provider/provider.dart';

class GameRecordDetails extends StatefulWidget {
  const GameRecordDetails({super.key});

  @override
  State<GameRecordDetails> createState() => _GameRecordDetailsState();
}

class _GameRecordDetailsState extends State<GameRecordDetails> {
  ImageConverterService imageConverterService = ImageConverterService();
  @override
  Widget build(BuildContext context) {
    final GameRecordProvider gameRecordProvider =
        context.watch<GameRecordProvider>();

    String base64Image = gameRecordProvider.record.game.original;
    Future<CanvasModel> images = imageConverterService.fromImagesBase64(
      gameRecordProvider.record.game.original,
      gameRecordProvider.record.game.modified,
    );

    print("yes ${gameRecordProvider.record.game.name}");
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Game Details"), // Optionally, include an AppBar for better navigation/UI
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Uint8List>(
              future: Future.value(
                  imageConverterService.uint8listFromBase64String(
                      gameRecordProvider.record.game.original)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    width: double.infinity,
                    height: 498,
                    fit: BoxFit.scaleDown,
                  );
                } else {
                  return Text("Unable to load image");
                }
              },
            ),
            Text("Game: ${gameRecordProvider.record.game.name}"),
            Text(
              "Date: ${gameRecordProvider.record.date})",
            ),
            Text("Duration: ${gameRecordProvider.record.duration} seconds"),
            Text(
                "Cheat Enabled: ${gameRecordProvider.record.isCheatEnabled ? "Yes" : "No"}"),
            Text(
                "Game event 1 : ${gameRecordProvider.record.gameEvents[0].gameEvent}"),
            const Divider(),
            Text("Players:"),
            ...gameRecordProvider.record.players
                .map((player) => Text(player.name!))
                .toList(), // Ensure .toList() is called
            const Divider(),
            Text("Game Events:"),
            ...gameRecordProvider.record.gameEvents
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
                      .addAccountIdByDate(gameRecordProvider.record.date);
                }) // Ensure .toList() is called
          ],
        ),
      ),
    );
  }
}
