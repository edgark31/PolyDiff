import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
            action: connection.isConnection
                ? AppLocalizations.of(context)!.history_connection
                : AppLocalizations.of(context)!.history_disconnection,
          ),
        )
        .toList();

    final List<GameHistory> gameHistory = infoService.sessions
        .map((session) => GameHistory(
              dateTime: session.timestamp,
              won: session.isWinner,
            ))
        .toList();

    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.history_title),
      body: BackgroundContainer(
        backgroundImagePath: infoService.isThemeLight
            ? MENU_BACKGROUND_PATH
            : MENU_BACKGROUND_PATH_DARK,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSectionTitle(context,
                AppLocalizations.of(context)!.history_connectionHistory),
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
            _buildSectionTitle(
                context, AppLocalizations.of(context)!.history_gameHistory),
            Expanded(
              child: Scrollbar(
                child: ListView(
                  children: gameHistory
                      .map((e) => ListTile(
                            title: Text(e.won
                                ? AppLocalizations.of(context)!.history_wonGame
                                : AppLocalizations.of(context)!
                                    .history_lostGame),
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
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
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
