import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/room_data_provider.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  static const routeName = GAME_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const GamePage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> roomDataProvider = Provider.of<RoomDataProvider>(context).roomData;
    print(Provider.of<RoomDataProvider>(context).player1);
    print(Provider.of<RoomDataProvider>(context).player2);

    return Scaffold(
      body: roomDataProvider.roomData['isJoin'] ? :
      Center(
          child:
              Text(Provider.of<RoomDataProvider>(context).roomData.toString())),
    );
  }
}
