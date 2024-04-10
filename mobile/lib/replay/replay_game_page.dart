import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/players.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/replay_canvas_widget.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_player_provider.dart';
import 'package:mobile/replay/replay_service.dart';
import 'package:mobile/replay/replay_video_bar_widget.dart';
import 'package:provider/provider.dart';

class ReplayGamePage extends StatefulWidget {
  static const routeName = REPLAY_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => ReplayGamePage(),
    );
  }

  @override
  State<ReplayGamePage> createState() => _ReplayGamePageState();
}

class _ReplayGamePageState extends State<ReplayGamePage> {
  // Services
  final ReplayService replayService = Get.find<ReplayService>();
  final GameRecordProvider gameRecordProvider = Get.find<GameRecordProvider>();
  final ReplayImagesProvider replayImagesProvider =
      Get.find<ReplayImagesProvider>();

  @override
  void initState() {
    super.initState();

    gameRecordProvider.getDefault();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadImages();
      loadImage();
    });
    replayService.start();
  }

  void preloadImages() async {
    final ReplayService replayService =
        Provider.of<ReplayService>(context, listen: false);
    await replayService.preloadGameEventImages(context);
  }

  void loadImage() async {
    final ReplayService replayService =
        Provider.of<ReplayService>(context, listen: false);
    await replayService.loadInitialCanvas(context);
  }

  @override
  Widget build(BuildContext context) {
    final ReplayService replayService = context.watch<ReplayService>();
    final ReplayPlayerProvider replayPlayerProvider =
        context.watch<ReplayPlayerProvider>();
    ReplayImagesProvider replayImagesProvider =
        context.watch<ReplayImagesProvider>();

    int timer = replayService.replayTimer;

    String formattedTime =
        "${(timer ~/ 60).toString().padLeft(2, '0')}:${(timer % 60).toString().padLeft(2, '0')}";
    String gameMode = AppLocalizations.of(context)!.classicMode;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(GAME_BACKGROUND_PATH),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (replayService.record.isCheatEnabled) ...[
                      ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFFEF6151),
                          backgroundColor: Color(0xFF2D1E16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
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
                      height: 500,
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
                              '${AppLocalizations.of(context)!.gameInfos_differencesPresentTitle} : ${replayService.record.game.nDifferences}',
                              style: _textStyle(),
                              textAlign: TextAlign.center,
                            ),
                            Row(
                              children: [
                                if (replayService
                                    .record.players.isNotEmpty) ...[
                                  _playerInfo(
                                      replayPlayerProvider.getPlayer(0)),
                                ],
                                SizedBox(
                                  width: 130,
                                ),
                                if (replayService.record.players.length >
                                    1) ...[
                                  _playerInfo(
                                      replayPlayerProvider.getPlayer(1)),
                                ],
                              ],
                            ),
                            Row(
                              children: [
                                if (replayService.record.players.length >=
                                    3) ...[
                                  _playerInfo(
                                      replayPlayerProvider.getPlayer(2)),
                                ],
                                if (replayService.record.players.length >=
                                    4) ...[
                                  SizedBox(
                                    width: 130,
                                  ),
                                  _playerInfo(
                                      replayPlayerProvider.getPlayer(3)),
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
                FutureBuilder<CanvasModel>(
                  future: replayImagesProvider.currentCanvas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ReplayOriginalCanvas(snapshot.data),
                          SizedBox(width: 50),
                          ReplayModifiedCanvas(snapshot.data),
                        ],
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child:
                      ReplayTimelinePlayer(), // Always accessible at the bottom
                ),
              ],
            ),
          ),
        ],
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

  TextStyle _textStyle() {
    return TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }
}
