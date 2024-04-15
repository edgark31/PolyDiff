import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/models/game_record_model.dart';

class GameRecordCardWidget extends StatelessWidget {
  final GameRecordCard gameRecordCard;
  final VoidCallback onDelete;
  final VoidCallback onReplay;

  const GameRecordCardWidget(
      {super.key,
      required this.gameRecordCard,
      required this.onReplay,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.ondemand_video_rounded),
            title: Text(gameRecordCard.gameName),
            subtitle: Text(
                "${AppLocalizations.of(context)!.lobby_selection_players}: ${gameRecordCard.playerNames.join(', ')}\n"
                "Date: ${gameRecordCard.date}"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.slideshow_rounded),
                onPressed: onReplay,
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
