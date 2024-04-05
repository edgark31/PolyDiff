import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const routeName = HISTORY_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const HistoryPage(),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();

    final List<LoginHistory> loginHistory = infoService.connections
        .map(
          (connection) => LoginHistory(
              dateTime: connection.timestamp,
              action: connection.isConnection ? 'Connexion' : 'Déconnexion'),
        )
        .toList();

    final List<GameHistory> gameHistory = infoService.sessions
        .map((session) => GameHistory(
              dateTime: session.timestamp,
              won: session.isWinner,
            ))
        .toList();

    return Scaffold(
      appBar: CustomAppBar(title: 'H I S T O R I Q U E'),
      body: BackgroundContainer(
        backgroundImagePath: infoService.isThemeLight
            ? MENU_BACKGROUND_PATH
            : MENU_BACKGROUND_PATH_DARK,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSectionTitle(context, "Historique de Connexion"),
            Expanded(
              child: Scrollbar(
                child: ListView(
                  children: loginHistory
                      .map((e) => ListTile(
                            title: Text(e.action),
                            subtitle: Text("${e.dateTime}"),
                          ))
                      .toList(),
                ),
              ),
            ),
            _buildSectionTitle(context, "Historique des Parties"),
            Expanded(
              child: Scrollbar(
                child: ListView(
                  children: gameHistory
                      .map((e) => ListTile(
                            title: Text(e.won ? "Gagnée" : "Perdue"),
                            subtitle: Text("${e.dateTime}"),
                            leading: Icon(
                                e.won ? Icons.emoji_events : Icons.close,
                                color: e.won ? Colors.green : Colors.red),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title),
    );
  }
}

class LoginHistory {
  final String dateTime;
  final String action;

  LoginHistory({required this.dateTime, required this.action});
}

class GameHistory {
  final String dateTime;
  final bool won;

  GameHistory({required this.dateTime, required this.won});
}
