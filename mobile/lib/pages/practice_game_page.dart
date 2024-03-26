import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/services/coordinate_conversion_service.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/image_converter_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/canvas.dart';
import 'package:mobile/widgets/chat_box.dart';
import 'package:mobile/widgets/end_game_popup.dart';
import 'package:mobile/widgets/game_infos.dart';
import 'package:provider/provider.dart';

class PracticeGamePage extends StatefulWidget {
  static const routeName = PRACTICE_ROUTE;

  PracticeGamePage();

  @override
  State<PracticeGamePage> createState() => _PracticeGamePageState();

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => PracticeGamePage(),
      settings: RouteSettings(name: routeName),
    );
  }
}

class _PracticeGamePageState extends State<PracticeGamePage> {
  final ImageConverterService imageConverterService = ImageConverterService();
  final GameAreaService gameAreaService = Get.find();
  final GameManagerService gameManagerService = Get.find();
  late Future<CanvasModel> imagesFuture;
  bool isChatBoxVisible = false;
  final tempGameManager = CoordinateConversionService();

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
    final lobbyService = context.watch<LobbyService>();
    if (gameManagerService.game.gameId == '') {
      return Column(
        children: [
          CircularProgressIndicator(),
          Text('Chargement de la salle de jeu...'),
        ],
      );
    }

    if (gameManagerService.endGameMessage != null) {
      Future.delayed(Duration.zero, () {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return EndGamePopup(
                endMessage: gameManagerService.endGameMessage!,
                gameMode: lobbyService.lobby.mode,
              );
            },
          );
        }
      });
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
                  SizedBox(
                    height: 200,
                    width: 1000,
                    child: GameInfos(),
                  ),
                ],
              ),
              FutureBuilder<CanvasModel>(
                future: imagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OriginalCanvas(snapshot.data, '123'),
                        SizedBox(width: 50),
                        ModifiedCanvas(snapshot.data, '123'),
                      ],
                    );
                  } else {
                    print('NOT DONE');
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
          if (isChatBoxVisible)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              height: 550,
              child: Align(
                alignment: Alignment.topCenter,
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 500),
                  child: Transform.scale(
                    scale: 1.0,
                    child: ChatBox(),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: IconButton(
                icon: Icon(Icons.chat),
                iconSize: 45.0,
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    isChatBoxVisible = !isChatBoxVisible;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
