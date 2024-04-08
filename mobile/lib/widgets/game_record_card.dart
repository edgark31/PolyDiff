import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:provider/provider.dart';

class GameRecordCardWidget extends StatelessWidget {
  final GameRecordCard gameRecordCard;
  final VoidCallback onDelete;

  const GameRecordCardWidget(
      {super.key, required this.gameRecordCard, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final GameRecordProvider gameRecordProvider =
        context.watch<GameRecordProvider>();
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.ondemand_video_rounded),
            title: Text(gameRecordCard.gameName),
            // TODO: ajuster avec la translation
            subtitle: Text(
                "Players: ${gameRecordCard.playerNames.join(', ')}\nDuration: ${gameRecordCard.durationFormatted}"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                // TODO: ajuster avec la translation
                child: const Text('REJOUER'),
                onPressed: () {
                  gameRecordProvider.setGameRecordByDate(gameRecordCard.date);
                  Navigator.pushNamed(context, REPLAY_ROUTE);
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: onDelete,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
