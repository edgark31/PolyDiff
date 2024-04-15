import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/models/game_record_model.dart';

typedef OnReplayCallback = void Function(GameRecord gameRecord);

class GameRecordCardWidget extends StatelessWidget {
  final GameRecord gameRecord;
  final OnReplayCallback onReplay;
  final VoidCallback onDelete;

  GameRecordCardWidget({
    super.key,
    required this.gameRecord,
    required this.onReplay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.ondemand_video_rounded),
            title: Text(gameRecord.game.name),
            subtitle: Text(
                "${AppLocalizations.of(context)!.lobby_selection_players}: ${gameRecord.players.map((player) => player.name).join(', ')}\nDate: ${gameRecord.date}"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('REPLAY'),
                onPressed: () => onReplay(gameRecord),
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
