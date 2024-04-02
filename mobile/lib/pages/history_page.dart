import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';

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
    // TODO : Replace when logic is set up
    final List<LoginHistory> loginHistory = [
      LoginHistory(
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
          action: 'Connexion'),
      LoginHistory(
          dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          action: 'Déconnexion'),
    ];
    final List<GameHistory> gameHistory = [
      GameHistory(
          dateTime: DateTime.now().subtract(const Duration(days: 2)),
          won: true),
      GameHistory(
          dateTime: DateTime.now().subtract(const Duration(days: 3)),
          won: false),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: 'H I S T O R I Q U E'),
      body: BackgroundContainer(
        backgroundImagePath: SELECTION_BACKGROUND_PATH,
        child: ListView(
          children: [
            _buildSectionTitle(context, "Historique de Connexion"),
            _buildHistorySection(loginHistory
                .map((e) => ListTile(
                      title: Text(e.action),
                      subtitle: Text("${e.dateTime}"),
                    ))
                .toList()),
            _buildSectionTitle(context, "Historique des Parties"),
            _buildHistorySection(gameHistory
                .map((e) => ListTile(
                      title: Text(e.won ? "Gagnée" : "Perdue"),
                      subtitle: Text("${e.dateTime}"),
                      leading: Icon(e.won ? Icons.emoji_events : Icons.close,
                          color: e.won ? Colors.green : Colors.red),
                    ))
                .toList()),
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

  Widget _buildHistorySection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: children,
      ),
    );
  }
}

class LoginHistory {
  final DateTime dateTime;
  final String action;

  LoginHistory({required this.dateTime, required this.action});
}

class GameHistory {
  final DateTime dateTime;
  final bool won;

  GameHistory({required this.dateTime, required this.won});
}
