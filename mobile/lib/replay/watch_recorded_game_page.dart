import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/game_record_details_widget.dart';

class WatchRecordedGame extends StatefulWidget {
  const WatchRecordedGame({super.key});

  // static const routeName = REPLAY_ROUTE;

  // static Route<dynamic> route() {
  //   return MaterialPageRoute(
  //     builder: (_) => const WatchRecordedGame(),
  //     settings: RouteSettings(name: routeName),
  //   );
  // }

  @override
  State<WatchRecordedGame> createState() => _WatchRecordedGameState();
}

class _WatchRecordedGameState extends State<WatchRecordedGame> {
  final GameRecordProvider gameRecordProvider = Get.find();

  @override
  void initState() {
    super.initState();

    print('Getting all game records');
  }

  @override
  Widget build(BuildContext context) {
    return GameRecordDetails();
  }
}
