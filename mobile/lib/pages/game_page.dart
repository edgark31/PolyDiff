import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/observers_model.dart';
import 'package:mobile/services/coordinate_conversion_service.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/image_converter_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/abandon_popup.dart';
import 'package:mobile/widgets/canvas.dart';
import 'package:mobile/widgets/chat_box.dart';
import 'package:mobile/widgets/end_game_popup.dart';
import 'package:mobile/widgets/game_infos.dart';
import 'package:mobile/widgets/game_loading.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  static const routeName = GAME_ROUTE;

  GamePage();

  @override
  State<GamePage> createState() => _GamePageState();

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => GamePage(),
      settings: RouteSettings(name: routeName),
    );
  }
}

class _GamePageState extends State<GamePage> {
  final ImageConverterService imageConverterService = ImageConverterService();
  final GameAreaService gameAreaService = Get.find();
  final GameManagerService gameManagerService = Get.find();
  late Future<CanvasModel> imagesFuture;
  bool isChatBoxVisible = false;
  bool isCheatActivated = false;
  final tempGameManager = CoordinateConversionService();

  @override
  void initState() {
    super.initState();
    gameManagerService.onGameChange = () {
      print('Loading new images');
      if (gameManagerService.game.original == '' ||
          gameManagerService.game.modified == '') return;
      imagesFuture = loadImage(
        gameManagerService.game.original,
        gameManagerService.game.modified,
      );
    };
    gameAreaService.onCheatModeDeactivated = () {
      gameManagerService.deactivateCheat();
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
    final gameAreaService = Provider.of<GameAreaService>(context);
    final gameManagerService = context.watch<GameManagerService>();
    final lobbyService = context.watch<LobbyService>();
    final isPlayerAnObserver = lobbyService.isObserver;

    final canPlayerInteract =
        !isPlayerAnObserver; // TODO: Add condition for replay

    if (gameManagerService.game.gameId == '') {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/game_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(child: GameLoading()),
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
                isObserver: isPlayerAnObserver,
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
                  if (lobbyService.lobby.isCheatEnabled &&
                      !isPlayerAnObserver) ...[
                    ElevatedButton(
                      onPressed: () {
                        isCheatActivated = !isCheatActivated;
                        List<List<Coordinate>>? differences =
                            gameManagerService.game.differences;
                        List<Coordinate> mergedDifferences =
                            differences!.expand((x) => x).toList();
                        gameAreaService.toggleCheatMode(mergedDifferences);
                        if (gameAreaService.isCheatMode) {
                          gameManagerService.activateCheat();
                        } else {
                          gameManagerService.deactivateCheat();
                        }
                      },
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
                        'TRICHE',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ],
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
                        OriginalCanvas(snapshot.data, '123', canPlayerInteract),
                        SizedBox(width: 50),
                        ModifiedCanvas(snapshot.data, '123', canPlayerInteract),
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
          isPlayerAnObserver
              ? _actionButton(
                  context,
                  'Quitter',
                  () {
                    gameManagerService.abandonGame(lobbyService.lobby.lobbyId);
                    gameManagerService
                        .disconnectSocket(); // No event sent to server
                    lobbyService.setIsObserver(false);
                    lobbyService.leaveLobby();
                    Navigator.pushNamed(context, DASHBOARD_ROUTE);
                  },
                )
              : _actionButton(
                  context,
                  'Abandonner',
                  () {
                    Future.delayed(Duration.zero, () {
                      if (ModalRoute.of(context)?.isCurrent ?? false) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AbandonPopup();
                          },
                        );
                      }
                    });
                  },
                ),
          if (lobbyService.lobby.observers.isNotEmpty)
            _observerInfos(lobbyService.lobby.observers),
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

  Widget _actionButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return Positioned(
      left: 8.0,
      bottom: 8.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFFEF6151),
          backgroundColor: Color(0xFF2D1E16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(text, style: TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _observerInfos(List<Observer> observers) {
    String observerNames = observers.map((e) => e.name).join(', ');
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
              observerNames,
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
}
