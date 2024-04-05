import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_selection_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/custom_menu_drawer.dart';
import 'package:provider/provider.dart';

class CreateRoomOptionsPage extends StatefulWidget {
  const CreateRoomOptionsPage({super.key});

  static const routeName = CREATE_ROOM_OPTIONS_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const CreateRoomOptionsPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<CreateRoomOptionsPage> createState() => _CreateRoomOptionsPageState();
}

class _CreateRoomOptionsPageState extends State<CreateRoomOptionsPage> {
  final ChatService chatService = Get.find();
  bool cheatMode = true;
  double gameDuration = 30;
  double gameBonus = 10;

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    final lobbySelectionService = context.watch<LobbySelectionService>();
    final chatService = context.watch<ChatService>();
    final infoService = context.watch<InfoService>();

    String gameModeName = lobbyService.gameModes == GameModes.Classic
        ? AppLocalizations.of(context)!.classicMode
        : AppLocalizations.of(context)!.limitedMode;

    return BackgroundContainer(
      backgroundImagePath: infoService.isThemeLight
          ? SELECTION_BACKGROUND_PATH
          : SELECTION_BACKGROUND_PATH_DARK,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
            title: AppLocalizations.of(context)!.create_room_options_title),
        drawer: CustomMenuDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(16.0),
                child: Text(
                  '${AppLocalizations.of(context)!.create_room_options_selectionText} $gameModeName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              cheatSetting(context),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
              ),
              timeSelection(context),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
              ),
              if (lobbyService.gameModes == GameModes.Limited) ...[
                bonusTimeSelection(context),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                ),
              ],
              CustomButton(
                press: () {
                  lobbySelectionService.setIsCheatEnabled(cheatMode);
                  lobbySelectionService.setGameDuration(gameDuration.round());
                  lobbySelectionService.setGameBonus(gameBonus.round());
                  lobbyService.createLobby();
                  chatService.setLobbyMessages([]); // Creator has no messages
                  Future.delayed(Duration(milliseconds: 500), () {
                    // Waiting for server to emit the created lobby from creator
                    Navigator.pushNamed(context, LOBBY_ROUTE);
                  });
                },
                text: AppLocalizations.of(context)!
                    .create_room_options_createText,
                widthFactor: 0.25,
              ),
              CustomButton(
                press: () {
                  Navigator.pushNamed(context, DASHBOARD_ROUTE);
                },
                text:
                    AppLocalizations.of(context)!.create_room_options_backText,
                widthFactor: 0.25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cheatSetting(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.create_room_options_cheatSetting),
        Checkbox(
          value: cheatMode,
          onChanged: (bool? newValue) {
            setState(() {
              cheatMode = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget timeSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.create_room_options_initialTime),
        Slider(
          value: gameDuration,
          min: 30,
          max: 600, // TODO: Change back to 60 when testing is done
          divisions: 30,
          label: gameDuration.round().toString(),
          onChanged: (double newValue) {
            setState(() {
              gameDuration = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget bonusTimeSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.create_room_options_bonusTime),
        Slider(
          value: gameBonus,
          min: 10,
          max: 20,
          divisions: 10,
          label: gameBonus.round().toString(),
          onChanged: (double newValue) {
            setState(() {
              gameBonus = newValue;
            });
          },
        ),
      ],
    );
  }
}
