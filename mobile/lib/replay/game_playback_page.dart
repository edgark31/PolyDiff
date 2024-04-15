import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
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

class GameEventPlaybackScreen extends StatefulWidget {
  static const String routeName = REPLAY_ROUTE;

  GameEventPlaybackScreen();

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => GameEventPlaybackScreen(),
    );
  }

  @override
  State<GameEventPlaybackScreen> createState() =>
      _GameEventPlaybackScreenState();
}

class _GameEventPlaybackScreenState extends State<GameEventPlaybackScreen> {
  late StreamSubscription<GameEventData> _subscription;

  // GameEventPlaybackManager playbackManager = Get.find();
  // ReplayImagesProvider replayImagesProvider = Get.find();
  // ReplayPlayerProvider replayPlayerProvider = Get.find();
  late GameEventData gameEvent;
  // GameRecordProvider gameRecordProvider = Get.find();
  bool isCheatActivated = false;
  bool isAnimationPaused = false;
  // String formattedTime = "00:00";

  @override
  void initState() {
    super.initState();
    // GameRecordProvider gameRecordProvider = Get.find();
    // ReplayPlayerProvider replayPlayerProvider = Get.find();

    // gameRecordProvider = Get.find();
    // Initialize services and providers
    // playbackService = Get.find();
    // replayImagesProvider = Get.find();
    // replayPlayerProvider = Get.find();
    // playbackManager = Get.find();
    // replayPlayerProvider.setPlayersData(gameRecordProvider.record.players);
    // // formattedTime = calculateFormattedTime(playbackManager.timer);
    // replayPlayerProvider
    //     .setNumberOfObservers(gameRecordProvider.record.observers);

    loadInitialCanvas();

    subscribeToEvents();
  }

  void loadInitialCanvas() async {
    GameRecordProvider gameRecordProvider = Get.find();
    ReplayImagesProvider replayImagesProvider = Get.find();
    try {
      await replayImagesProvider.loadInitialCanvas(gameRecordProvider.record);
    } catch (e) {
      print("Failed to load initial canvas: $e");

      showErrorDialog("Failed to load game data. Please try again.");
    }
  }

  void subscribeToEvents() {
    GameEventPlaybackService playbackService = Get.find();
    playbackService.startPlayback();
    _subscription = playbackService.eventsStream.listen((GameEventData event) {
      setState(() {
        gameEvent = event; // Update the current event
        if (event.gameEvent == GameEvents.EndGame.name) {
          print("****** End Game ******");
          _showReplayPopUp();
        } else {
          // formattedTime = calculateFormattedTime(event.time!);
        }
        print("****** Set State from screen page ******");
      });
    }, onError: (error) {
      print("Error receiving game event: $error");
      showErrorDialog("An error occurred while processing game events.");
    });
  }

  void showErrorDialog(String message) {
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
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // String calculateFormattedTime(int timeInSeconds) {
  //   int elapsedTime =
  //       (gameRecordProvider.record.duration * 1000) - timeInSeconds;

  //   Duration duration = Duration(milliseconds: elapsedTime);

  //   if (elapsedTime.isNegative) {
  //     return "00:00";
  //   }
  //   int minutes = duration.inMinutes;
  //   int seconds = duration.inSeconds % 60;
  //   return '$minutes:${seconds.toString().padLeft(2, '0')}';
  // }

  void _leaveReplayPage() {
    // gameRecordProvider.setIsFromProfile(false);
    Navigator.pushNamed(context, DASHBOARD_ROUTE);
  }

  void _showReplayPopUp() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // The user must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("hi"),
          content: Text("hiyaaa"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _leaveReplayPage(); // Navigate away from the replay page
              },
              child:
                  Text(AppLocalizations.of(context)!.confirmation_no),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                // Optionally, you can add any specific actions you might need here
              },
              child:
                  Text(AppLocalizations.of(context)!.confirmation_yes),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    GameEventPlaybackService playbackService =
        context.read<GameEventPlaybackService>();
    // Providers
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
                if (playbackService.gameRecord.isCheatEnabled) ...[
                  ElevatedButton(
                    onPressed: () {},
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
            if (gameEvent.gameEvent == GameEvents.EndGame.name) ...[
              ElevatedButton(
                onPressed: () {
                  _showReplayPopUp();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "test test test",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          left: 8.0,
          bottom: 8.0,
          child: ElevatedButton(
            onPressed: () {
              _leaveReplayPage();
              // TODO : Implement home functionality
              // if (gameRecordProvider.isFromProfile()) {
              //   _leaveReplayPage();
              // } else {
              //   AlertDialog(
              //     title: Text("Going back to home"),
              //     content: Text("Do you want to save the replay?"),
              //     actions: <Widget>[
              //       TextButton(
              //         child:
              //             Text(AppLocalizations.of(context)!.confirmation_no),
              //         onPressed: () {
              //           gameRecordProvider
              //               .deleteAccountId(gameRecordProvider.record.date);
              //           _leaveReplayPage();
              //         },
              //       ),
              //       TextButton(
              //         child:
              //             Text(AppLocalizations.of(context)!.confirmation_yes),
              //         onPressed: () {
              //           _leaveReplayPage();
              //         },
              //       ),
              //     ],
              //   );
              // }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.home, color: Colors.white)],
              ),
            ),
          ),
        ),
        Positioned(
          left: 10.0,
          right: 0.0,
          bottom: 8.0,
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
        _observerInfos(playbackManager.nObservers),

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
    GameEventPlaybackManager playbackManager = Get.find();
    ReplayPlayerProvider replayPlayerProvider = Get.find();
    GameRecordProvider gameRecordProvider = Get.find();
    String formattedTime =
        "${(playbackManager.timer ~/ 60).toString().padLeft(2, '0')}:${(playbackManager.timer % 60).toString().padLeft(2, '0')}";
    String gameMode = AppLocalizations.of(context)!.classicMode;

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
                  '${AppLocalizations.of(context)!.gameInfos_timeTitle} : ${formattedTime}',
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
                if (gameRecordProvider.record.players.isNotEmpty) ...[
                  _playerInfo(replayPlayerProvider.getPlayer(0)),
                ],
                SizedBox(
                  width: 20,
                ),
                if (gameRecordProvider.record.players.length > 1) ...[
                  _playerInfo(replayPlayerProvider.getPlayer(1)),
                ],
              ],
            ),
            Row(
              children: [
                if (gameRecordProvider.record.players.length >= 3) ...[
                  _playerInfo(replayPlayerProvider.getPlayer(2)),
                ],
                if (gameRecordProvider.record.players.length >= 4) ...[
                  SizedBox(
                    width: 20,
                  ),
                  _playerInfo(replayPlayerProvider.getPlayer(3)),
                ],
              ],
            )
          ],
        ));
  }
}


// Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Popup Demo')),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: Text('Popup Title'),
//                     content: Text('This is a simple popup dialog.'),
//                     actions: <Widget>[
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                         child: Text('Close'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             child: Text('Show Popup'),
//           ),
//         ),
//       ),
//     );
//   }