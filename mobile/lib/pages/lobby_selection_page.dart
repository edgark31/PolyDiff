import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:provider/provider.dart';

class LobbySelectionPage extends StatefulWidget {
  const LobbySelectionPage({Key? key});

  static const routeName = LOBBY_SELECTION_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const LobbySelectionPage(),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  State<LobbySelectionPage> createState() => _LobbySelectionPageState();
}

class _LobbySelectionPageState extends State<LobbySelectionPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    final infoService = context.watch<InfoService>();
    String creationRoute = lobbyService.isGameModesClassic()
        ? CREATE_ROOM_CARD_ROUTE
        : CREATE_ROOM_OPTIONS_ROUTE;
    final lobbiesFromServer = lobbyService.filterLobbies();
    String gameModeName = lobbyService.gameModes == GameModes.Classic
        ? AppLocalizations.of(context)!.classicMode
        : AppLocalizations.of(context)!.limitedMode;

    return BackgroundContainer(
      backgroundImagePath: infoService.isThemeLight
          ? LIMITED_TIME_BACKGROUND_PATH
          : LIMITED_TIME_BACKGROUND_PATH_DARK,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context)!.lobby_selection_title,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      CustomButton(
                        text:
                            '${AppLocalizations.of(context)!.lobby_selection_createRoom} $gameModeName',
                        press: () =>
                            Navigator.pushNamed(context, creationRoute),
                        widthFactor: 0.5,
                      ),
                      const SizedBox(height: 10),
                      lobbiesFromServer.isEmpty
                          ? Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(16.0),
                              margin: const EdgeInsets.all(16.0),
                              child: Text(
                                '${AppLocalizations.of(context)!.lobby_selection_noRoom} $gameModeName',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: lobbiesFromServer.length,
                              itemBuilder: (context, index) {
                                return buildLobbyCard(
                                    context, lobbiesFromServer[index]);
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget buildLobbyCard(BuildContext context, Lobby lobby) {
    bool isLobbyClassic = lobby.mode == GameModes.Classic;
    String lobbyName = isLobbyClassic
        ? AppLocalizations.of(context)!.classicMode
        : AppLocalizations.of(context)!.limitedMode;
    String classicImagePath = '$BASE_URL/${lobby.gameId}/original.bmp';
    ImageProvider<Object>? lobbyImage = isLobbyClassic
        ? Image.network(classicImagePath).image
        : const AssetImage('assets/images/limitedTime.png');
    String differences =
        isLobbyClassic ? 'Differences: ${lobby.nDifferences}, ' : '';
    String nPlayers =
        '${AppLocalizations.of(context)!.lobby_selection_nPlayers}: ${lobby.players.length}/4';
    String playerNames = lobby.players.map((e) => e.name).join(', ');
    final lobbyService = context.watch<LobbyService>();
    final chatService = context.watch<ChatService>();
    final gameManagerService = context.watch<GameManagerService>();

    bool areObservers = lobby.observers.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: lobbyImage,
                radius: 30,
                backgroundColor: kLight,
              ),
              title: Text(lobbyName),
              subtitle: Text('$differences$nPlayers'),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                          '${AppLocalizations.of(context)!.lobby_selection_players}: $playerNames',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                        child: areObservers
                            ? const Icon(
                                Icons.remove_red_eye,
                                color: Colors.black,
                              )
                            : const Icon(
                                Icons.visibility_off,
                                color: Colors.black,
                              )),
                  ]),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                lobby.isAvailable
                    ? (lobby.players.length == 4
                        ? Text(AppLocalizations.of(context)!
                            .lobby_selection_fullRoom)
                        : CustomButton(
                            press: () {
                              lobbyService.joinLobby(lobby.lobbyId);
                              chatService.setLobbyMessages(lobby.chatLog!.chat);
                              Navigator.pushNamed(context, LOBBY_ROUTE);
                            },
                            text: AppLocalizations.of(context)!
                                .lobby_selection_join,
                            widthFactor: 1.5,
                          ))
                    : CustomButton(
                        text: AppLocalizations.of(context)!
                            .lobby_selection_observe,
                        press: () {
                          print(
                              'Player is joining as observer in lobby ${lobby.lobbyId}');
                          lobbyService.spectateLobby(lobby.lobbyId);
                          chatService.setLobbyMessages(lobby.chatLog!.chat);
                          // Directly jump to GameLogic
                          gameManagerService.spectateLobby(lobby.lobbyId);
                          chatService.setGameChatListeners();
                          Navigator.pushNamed(context, GAME_ROUTE);
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
