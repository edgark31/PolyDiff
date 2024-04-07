import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/replay_service.dart';
import 'package:mobile/services/image_converter_service.dart';
import 'package:mobile/widgets/game_infos.dart';
import 'package:mobile/widgets/timeline_widget.dart';
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

  // late Future<CanvasModel> images;

  @override
  void initState() {
    super.initState();
    // images = loadImage(gameRecordProvider.record.game.original,
    //     gameRecordProvider.record.game.modified);
    replayService.setUpGameReplay();
    replayService.start();
  }

  // Future<CanvasModel> loadImage(
  //   String originalImage,
  //   String modifiedImage,
  // ) async {
  //   return imageConverterService.fromImagesBase64(originalImage, modifiedImage);
  // }

  @override
  Widget build(BuildContext context) {
    final isReplayMode = replayService.isReplaying;
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
                    height: 200,
                    width: 1000,
                    child: GameInfos(),
                  ),
                ],
              ),

              //     FutureBuilder<CanvasModel>(
              //       future: images,
              //       builder: (context, snapshot) {
              //         if (snapshot.connectionState == ConnectionState.done) {
              //           return Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               OriginalCanvas(snapshot.data, '123', false),
              //               SizedBox(width: 50),
              //               ModifiedCanvas(snapshot.data, '123', false),
              //             ],
              //           );
              //         } else {
              //           return CircularProgressIndicator();
              //         }
              //       },
              //     ),
              //   ],
              // ),
              Positioned(
                bottom: 0,
                child: TimelineWidget(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
