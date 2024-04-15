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
import 'package:mobile/replay/playback_manager.dart';
import 'package:mobile/replay/playback_service.dart';
import 'package:mobile/replay/playback_slider.dart';
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
  final PlaybackService playbackService = Get.find();
  final PlaybackManager playbackManager = Get.find();
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
        builder: (BuildContext context) {
          return AlertDialog(
            // TODO: traduire
            title: Text("Playback Finished"),
            content: Text("Would you like to replay?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    playbackService.restart();
                  },
                  child: Text("Yes")),
              TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, DASHBOARD_ROUTE),
                  child: Text("No")),
            ],
          );
        });
  }

  void _askPlayerToSaveReplay() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // TODO: traduire
            title: Text("Playback Finished"),
            content: Text("Would you like to save?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, DASHBOARD_ROUTE);
                  },
                  child: Text("Yes")),
              TextButton(
                onPressed: () {
                  gameRecordProvider
                      .deleteAccountId(gameRecordProvider.record.date);
                  Navigator.pushNamed(context, DASHBOARD_ROUTE);
                },
                child: Text("No"),
              ),
            ],
          );
        });
  }

  void showErrorDialog(String message) {
    // TODO: remove or translate
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
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

    final PlaybackManager playbackManager = context.watch<PlaybackManager>();

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
                if (gameRecordProvider.record.isCheatEnabled) ...[
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
        // if (isChatBoxVisible)
        //   Positioned(
        //     top: 50,
        //     left: 0,
        //     right: 0,
        //     height: 550,
        //     child: Align(
        //       alignment: Alignment.topCenter,
        //       child: AnimatedOpacity(
        //         opacity: 1.0,
        //         duration: Duration(milliseconds: 500),
        //         child: Transform.scale(
        //           scale: 1.0,
        //           child: ChatBox(),
        //         ),
        //       ),
        //     ),
        //   ),
        // isPlayerAnObserver
        //     ? _actionButton(
        //         context,
        //         AppLocalizations.of(context)!.gamePage_leaveButton,
        //         () {
        //           gameManagerService.abandonGame(lobbyService.lobby.lobbyId);
        //           Navigator.pushNamed(context, DASHBOARD_ROUTE);
        //         },
        //       )
        //     : _actionButton(
        //         context,
        //         AppLocalizations.of(context)!.gamePage_giveUpButton,
        //         () {
        //           Future.delayed(Duration.zero, () {
        //             if (ModalRoute.of(context)?.isCurrent ?? false) {
        //               showDialog(
        //                 barrierDismissible: false,
        //                 context: context,
        //                 builder: (BuildContext context) {
        //                   return AbandonPopup();
        //                 },
        //               );
        //             }
        //           });
        //         },
        //       ),
        // _observerInfos(replayPlayerProvider.nObservers),
        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: Padding(
        //     padding: const EdgeInsets.only(bottom: 20.0),
        //     child: IconButton(
        //       icon: Icon(Icons.chat),
        //       iconSize: 45.0,
        //       color: Colors.white,
        //       onPressed: () {
        //         setState(() {
        //           isChatBoxVisible = !isChatBoxVisible;
        //         });
        //       },
        //     ),
        //   ),
        // ),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 3.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlaybackSlider(
                playbackService: playbackService,
                playbackManager: playbackManager,
              ),
            ],
          ),
        ),

        // Positioned(
        //   left: 0.0,
        //   right: 0.0,
        //   bottom: 8.0,
        //   child: Row(
        //     children: [
        // Directly place the GameEventSlider without any flex-related wrapper
        // GameEventSlider(
        //   playbackService: playbackService,
        //   playbackManager: playbackManager,
        // ),
        // // You can control the space between the slider and the observer info,
        // // for example using a SizedBox if necessary.
        // SizedBox(width: 8), // Adjust the width as needed
        _observerInfos(replayPlayerProvider.nObservers),
        //     ],
        //   ),
        // )
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
