import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/models/players.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/game_event_playback_manager.dart';
import 'package:mobile/replay/game_event_slider.dart';
import 'package:mobile/replay/game_events_services.dart';
import 'package:mobile/replay/replay_canvas_widget.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:provider/provider.dart';

class PlaybackPage extends StatefulWidget {
  static const String routeName = REPLAY_ROUTE;

  PlaybackPage();

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => PlaybackPage(),
    );
  }

  @override
  State<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  late StreamSubscription<GameEventData> _subscription;
  final GameRecordProvider gameRecordProvider = Get.find();
  final GameEventPlaybackService playbackService = Get.find();
  final GameEventPlaybackManager playbackManager = Get.find();
  final ReplayImagesProvider replayImagesProvider = Get.find();
  late GameEventData gameEvent;

  bool get isEndGame => playbackManager.isEndGame;
  bool get isCheatMode => playbackManager.isCheatMode;
  bool get hasCheatModeEnabled => gameRecordProvider.hasCheatEnabled;

  @override
  void initState() {
    super.initState();

    loadInitialCanvas();
    subscribeToEvents();
    playbackService.setOnPlaybackComplete(_askPlayerToReplay);
    playbackService.setGamePlaybackComplete(_askPlayerToSaveReplay);
  }

  void loadInitialCanvas() async {
    try {
      await replayImagesProvider.loadInitialCanvas(gameRecordProvider.record);
    } catch (e) {
      print("Failed to load initial canvas: $e");

      showErrorDialog("Failed to load game data. Please try again.");
    }
  }

  void subscribeToEvents() {
    playbackService.startPlayback();
    _subscription = playbackService.eventsStream.listen((GameEventData event) {
      setState(() {
        gameEvent = event; // Update the current event
        print("PLAYBACK PAGE --> Received game event: ${event.gameEvent}");
      });
    }, onError: (error) {
      print("Error receiving game event: $error");
      showErrorDialog("An error occurred while processing game events.");
    });
  }

  void _askPlayerToReplay() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.replay_endOfReplay),
            content: Text(AppLocalizations.of(context)!.replay_wantToReplay),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    playbackService.restart();
                  },
                  child: Text(AppLocalizations.of(context)!.confirmation_yes)),
              TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, DASHBOARD_ROUTE),
                  child: Text(AppLocalizations.of(context)!.confirmation_no)),
            ],
          );
        });
  }

  void _askPlayerToSaveReplay() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.replay_endOfReplay),
            content: Text(AppLocalizations.of(context)!.replay_wantToSave),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, DASHBOARD_ROUTE);
                  },
                  child: Text(AppLocalizations.of(context)!.confirmation_yes)),
              TextButton(
                onPressed: () {
                  gameRecordProvider
                      .deleteAccountId(gameRecordProvider.record.date);
                  Navigator.pushNamed(context, DASHBOARD_ROUTE);
                },
                child: Text(AppLocalizations.of(context)!.confirmation_no),
              ),
            ],
          );
        });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Aie"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Providers
    final GameRecordProvider gameRecordProvider =
        context.read<GameRecordProvider>();

    final ReplayPlayerProvider replayPlayerProvider =
        context.watch<ReplayPlayerProvider>();
    final ReplayImagesProvider replayImagesProvider =
        context.watch<ReplayImagesProvider>();

    final GameEventPlaybackManager playbackManager =
        context.watch<GameEventPlaybackManager>();

    final InfoService infoService = context.watch<InfoService>();

    return Scaffold(
        body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(infoService.isThemeLight
                  ? GAME_BACKGROUND_PATH
                  : GAME_BACKGROUND_PATH_DARK),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 120),
                SizedBox(
                  height: 200,
                  width: 1000,
                  child: _gameInfosReplay(),
                ),
              ],
            ),
            FutureBuilder<CanvasModel>(
              future: replayImagesProvider.currentCanvas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ReplayOriginalCanvas(snapshot.data!),
                      ),
                      SizedBox(width: 50),
                      Expanded(child: ReplayModifiedCanvas(snapshot.data!)),
                    ],
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return Text("No data available");
                }
              },
            ),
          ],
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 3.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameEventSlider(
                playbackService: playbackService,
                playbackManager: playbackManager,
              ),
            ],
          ),
        ),
        _observerInfos(replayPlayerProvider.nObservers),
      ],
    ));
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  TextStyle _textStyle() {
    return TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  Widget _observerInfos(int nObservers) {
    if (nObservers == 0) {
      return Positioned(
        right: 8.0,
        bottom: 8.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.visibility_off, color: Colors.white)],
          ),
        ),
      );
    }

    return Positioned(
      right: 8.0,
      bottom: 8.0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye, color: Colors.white),
            SizedBox(width: 8),
            Text(
              nObservers.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerInfo(Player player) {
    return Row(
      children: [
        Icon(
          Icons.person,
          color: Colors.black,
          size: 30,
        ),
        Text(
          player.name!,
          style: _textStyle(),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          width: 30,
        ),
        Text(
          '${AppLocalizations.of(context)!.gameInfos_differencesFoundTitle} : ${player.count}',
          style: _textStyle(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _gameInfosReplay() {
    String formattedTime =
        "${(playbackManager.timer ~/ 60).toString().padLeft(2, '0')}:${(playbackManager.timer % 60).toString().padLeft(2, '0')}";
    String gameMode = AppLocalizations.of(context)!.classicMode;
    final List<Player> players = gameRecordProvider.record.players;
    final ReplayPlayerProvider playerProvider = Get.find();

    return SizedBox(
        width: 100,
        height: 50,
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 380),
                Text(
                  '${AppLocalizations.of(context)!.gameInfos_gameModeTitle} : $gameMode',
                  style: _textStyle(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 100),
                Text(
                  '${AppLocalizations.of(context)!.gameInfos_timeTitle} : $formattedTime',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Text(
              '${AppLocalizations.of(context)!.gameInfos_differencesPresentTitle} : ${gameRecordProvider.record.game.nDifferences}',
              style: _textStyle(),
              textAlign: TextAlign.center,
            ),
            Row(
              children: [
                if (players.isNotEmpty) ...[
                  _playerInfo(playerProvider.getPlayer(0)),
                ],
                SizedBox(
                  width: 20,
                ),
                if (players.length > 1) ...[
                  _playerInfo(playerProvider.getPlayer(1)),
                ],
              ],
            ),
            Row(
              children: [
                if (players.length >= 3) ...[
                  _playerInfo(playerProvider.getPlayer(2)),
                ],
                if (players.length >= 4) ...[
                  SizedBox(
                    width: 20,
                  ),
                  _playerInfo(playerProvider.getPlayer(3)),
                ],
              ],
            )
          ],
        ));
  }
}
