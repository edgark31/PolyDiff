import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
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
  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  Widget _gameModeOption(GameModes type, IconData icon, Color color) {
    final lobbyService = context.watch<LobbyService>();
    final socketService = context.watch<SocketService>();
    final infoService = context.watch<InfoService>();

    return CustomButton(
      text: type == GameModes.Classic ? 'Classique' : 'Temps limité',
      press: () {
        socketService.setup(SocketType.Lobby, infoService.id);
        lobbyService.setListeners();
        lobbyService.setGameModes(type);
        _navigateTo(LOBBY_SELECTION_ROUTE);
      },
      backgroundColor: color,
      icon: icon,
      widthFactor: 0.30,
      height: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      backgroundImagePath: SELECTION_BACKGROUND_PATH,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: CustomMenuDrawer(),
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, bottom: 20.0),
                    child: Text(
                      'SÉLECTIONNER UN MODE DE JEU',
                      style: TextStyle(
                          fontSize: 30,
                          color: kMidOrange,
                          backgroundColor: kLight,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
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
                  SizedBox(height: 50),
                  CustomButton(
                    text: 'Observer une parte',
                    press: () {
                      print(
                          'Navigating to Observer Selection Page'); // TODO: Observer Selection Page
                    },
                    backgroundColor: kLime,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
