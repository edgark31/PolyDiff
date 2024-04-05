import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/stroked_text_widget.dart';
import 'package:mobile/widgets/widgets.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const routeName = DASHBOARD_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const DashboardPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Widget _gameModeOption(GameModes type, IconData icon, Color color) {
    final lobbyService = context.watch<LobbyService>();
    final socketService = context.watch<SocketService>();
    final infoService = context.watch<InfoService>();
    final chatService = context.watch<ChatService>();
    String typeText = '';
    switch (type) {
      case GameModes.Classic:
        typeText = AppLocalizations.of(context)!.classicMode;
      case GameModes.Limited:
        typeText = AppLocalizations.of(context)!.limitedMode;
      case GameModes.Practice:
        typeText = AppLocalizations.of(context)!.practiceMode;
      default:
    }

    return CustomButton(
      text: typeText,
      press: () {
        socketService.setup(SocketType.Lobby, infoService.id);
        chatService.setupLobby();
        lobbyService.setupLobby(type);
        if (type == GameModes.Practice) {
          Navigator.pushNamed(context, CREATE_ROOM_CARD_ROUTE);
        } else {
          Navigator.pushNamed(context, LOBBY_SELECTION_ROUTE);
        }
      },
      icon: icon,
      widthFactor: 0.30,
      height: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();

    double screenHeight = MediaQuery.of(context).size.height;
    double startingPoint = screenHeight * 0.05;
    return BackgroundContainer(
      backgroundImagePath: infoService.isThemeLight
          ? EMPTY_BACKGROUND_PATH
          : EMPTY_BACKGROUND_PATH_DARK,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: CustomMenuDrawer(),
        appBar: CustomAppBar(title: ''),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: startingPoint),
                    child: StrokedTextWidget(
                      text: AppLocalizations.of(context)!.dashboard_welcomeText,
                      textStyle: TextStyle(
                        fontFamily: 'troika',
                        fontSize: 140,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8A430),
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _gameModeOption(
                    GameModes.Classic,
                    Icons.class_,
                    kMidOrange,
                  ),
                  SizedBox(height: 20),
                  _gameModeOption(
                    GameModes.Limited,
                    Icons.hourglass_bottom,
                    kMidGreen,
                  ),
                  SizedBox(height: 20),
                  _gameModeOption(
                    GameModes.Practice,
                    Icons.fitness_center,
                    kMidPink,
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
