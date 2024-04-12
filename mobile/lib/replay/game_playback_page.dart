import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/models/players.dart';
import 'package:mobile/replay/game_event_playback_manager.dart';
import 'package:mobile/replay/game_event_slider.dart';
import 'package:mobile/replay/game_events_services.dart';
import 'package:mobile/replay/replay_canvas_widget.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:provider/provider.dart';

class GameEventPlaybackScreen extends StatefulWidget {
  static const String routeName = REPLAY_ROUTE;
  final GameRecord record;

  GameEventPlaybackScreen({required this.record});

  static Route route(GameRecord record) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => GameEventPlaybackScreen(record: record),
    );
  }

  @override
  State<GameEventPlaybackScreen> createState() =>
      _GameEventPlaybackScreenState();
}

class _GameEventPlaybackScreenState extends State<GameEventPlaybackScreen> {
  late GameEventPlaybackService playbackService;
  late GameEventPlaybackManager playbackManager;
  late ReplayImagesProvider replayImagesProvider;
  late ReplayPlayerProvider replayPlayerProvider;
  late GameEventData gameEvent;
  late Future<CanvasModel> _currentCanvas;
  late Timer timer;
  String formattedTime = "00:00";

  @override
  void initState() {
    super.initState();
    // Initialize the playback service
    playbackService = GameEventPlaybackService(defaultGameEvents);
    playbackManager = GameEventPlaybackManager();
    replayImagesProvider = Get.find();
    replayPlayerProvider = Get.find();

    replayImagesProvider.loadInitialCanvas(context, widget.record);
    replayImagesProvider.preloadGameEventImages(context, widget.record);
    replayPlayerProvider.setPlayersData(widget.record.players);
    _currentCanvas = replayImagesProvider.currentCanvasModel;

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        formattedTime = formattedTime =
            calculateFormattedTime(playbackService.lastEventTime);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playbackService.eventsStream.listen((GameEventData event) {
        print("Event received: ${event.gameEvent}");
        print("GAME EVENT MODIFIED: ${event.modified}");

        gameEvent = event;
        setState(() {
          formattedTime = calculateFormattedTime(event.timestamp);
        });
      });
    });
  }

  String calculateFormattedTime(DateTime timestamp) {
    // Calculate elapsed time since the start of the playback
    Duration elapsedTime =
        timestamp.difference(playbackService.events.first.timestamp);
    // Calculate minutes and seconds from the elapsed time
    int minutes = elapsedTime.inMinutes;
    int seconds = elapsedTime.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String gameMode = AppLocalizations.of(context)!.classicMode;

    // Providers
    final ReplayPlayerProvider replayPlayerProvider =
        context.watch<ReplayPlayerProvider>();

    ReplayImagesProvider replayImagesProvider =
        context.watch<ReplayImagesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Event Playback"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                if (widget.record.isCheatEnabled) ...[
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xFFEF6151),
                      backgroundColor: Color(0xFF2D1E16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.gamePage_cheatButton,
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ] else
                  SizedBox(width: 50),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: SizedBox(
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
                          '${AppLocalizations.of(context)!.gameInfos_differencesPresentTitle} : ${widget.record.game.nDifferences}',
                          style: _textStyle(),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          children: [
                            if (widget.record.players.isNotEmpty) ...[
                              _playerInfo(replayPlayerProvider.getPlayer(0)),
                            ],
                            SizedBox(
                              width: 130,
                            ),
                            if (widget.record.players.length > 1) ...[
                              _playerInfo(replayPlayerProvider.getPlayer(1)),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            if (widget.record.players.length >= 3) ...[
                              _playerInfo(replayPlayerProvider.getPlayer(2)),
                            ],
                            if (widget.record.players.length >= 4) ...[
                              SizedBox(
                                width: 130,
                              ),
                              _playerInfo(replayPlayerProvider.getPlayer(3)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),

            // Display the formatted time
            Text(
              'Time: $formattedTime',
              style: TextStyle(fontSize: 18),
            ),
            FutureBuilder<CanvasModel>(
              future: _currentCanvas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ReplayOriginalCanvas(snapshot.data!),
                      SizedBox(width: 50),
                      ReplayModifiedCanvas(snapshot.data!),
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

            Center(
              child: GameEventSlider(
                playbackService: playbackService,
                playbackManager: playbackManager,
                replayImagesProvider: replayImagesProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    playbackService.dispose();
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
}
