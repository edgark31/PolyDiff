import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  static const routeName = LOBBY_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const LobbyPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
