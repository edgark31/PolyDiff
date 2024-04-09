import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/players.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/replay_service.dart';
import 'package:mobile/services/services.dart';
import 'package:mobile/widgets/canvas.dart';
import 'package:mobile/widgets/game_loading.dart';
import 'package:mobile/widgets/timeline_widget.dart';
import 'package:provider/provider.dart';
// Import other required packages

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
  final ReplayService replayService = Get.find<ReplayService>();
  final ImageConverterService imageConverterService = ImageConverterService();
  final GameRecordProvider gameRecordProvider = Get.find<GameRecordProvider>();
  final GameManagerService gameManagerService = Get.find<GameManagerService>();

  late Future<CanvasModel> imagesFuture;

  @override
  void initState() {
    super.initState();
    gameManagerService.onGameChange = () {
      if (gameManagerService.game.original == '' ||
          gameManagerService.game.modified == '') return;
      imagesFuture = loadImage(
        gameManagerService.game.original,
        gameManagerService.game.modified,
      );
    };

    replayService.setUpGameReplay();
    replayService.start();
  }

  Future<CanvasModel> loadImage(
    String originalImage,
    String modifiedImage,
  ) async {
    return imageConverterService.fromImagesBase64(originalImage, modifiedImage);
  }

  @override
  Widget build(BuildContext context) {
    final gameManagerService = context.watch<GameManagerService>();
    final gameRecordProvider = context.watch<GameRecordProvider>();
    final infoService = context.watch<InfoService>();
    int timer = gameManagerService.time;
    String formattedTime =
        "${(timer ~/ 60).toString().padLeft(2, '0')}:${(timer % 60).toString().padLeft(2, '0')}";

    String gameMode = AppLocalizations.of(context)!.classicMode;

    if (gameManagerService.game.gameId == '') {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(infoService.isThemeLight
                ? GAME_BACKGROUND_PATH
                : GAME_BACKGROUND_PATH_DARK),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(child: GameLoading()),
      );
    }

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
                    SizedBox(width: 50),
                  SizedBox(
                    width: 200,
                    height: 1000,
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
                            '${AppLocalizations.of(context)!.gameInfos_differencesPresentTitle} : ${gameRecordProvider.record.game.nDifferences}',
                            style: _textStyle(),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            children: [
                              if (gameRecordProvider
                                  .record.players.isNotEmpty) ...[
                                _playerInfo(
                                    gameRecordProvider.record.players[0]),
                              ],
                              SizedBox(
                                width: 130,
                              ),
                              if (gameRecordProvider.record.players.length >
                                  1) ...[
                                _playerInfo(
                                    gameRecordProvider.record.players[1]),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              if (gameRecordProvider.record.players.length >=
                                  3) ...[
                                _playerInfo(
                                    gameRecordProvider.record.players[2]),
                              ],
                              if (gameRecordProvider.record.players.length >=
                                  4) ...[
                                SizedBox(
                                  width: 130,
                                ),
                                _playerInfo(
                                    gameRecordProvider.record.players[3]),
                              ],
                            ],
                          ),
                          FutureBuilder<CanvasModel>(
                            future: imagesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OriginalCanvas(snapshot.data, '123', false),
                                    SizedBox(width: 50),
                                    ModifiedCanvas(snapshot.data, '123', false),
                                  ],
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TimelineWidget(
                                replayDuration:
                                    gameRecordProvider.record.duration),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
