import 'package:flutter/material.dart';
import 'package:mobile/replay/replay_data_provider.dart';
import 'package:mobile/replay/socket_client.dart';
import 'package:mobile/replay/watch_game_replay_page.dart';
import 'package:mobile/utils/show_dialog_util.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  // LISTENERS
  void replayGameSuccessListener(BuildContext context) {
    _socketClient.on('ReplayGame', (record) {
      Provider.of<ReplayDataProvider>(context, listen: false)
          .loadRecordData(record);
      Navigator.pushNamed(context, WatchGameReplayPage.routeName);
    });
  }

  void errorOccurredListener(BuildContext context) {
    _socketClient.on('errorOccurred', (data) {
      showSnackBar(context, data);
    });
  }

  void endGameListener(BuildContext context) {
    _socketClient.on('endGame', (playerData) {
      showGameDialog(context, '${playerData['username']} won the game!');
      Navigator.popUntil(context, (route) => false);
    });
  }
}
