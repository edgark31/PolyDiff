import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/replay/game_record_details_widget.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/timeline_widget.dart';

class WatchRecordedGame extends StatefulWidget {
  const WatchRecordedGame({super.key});

  static const routeName = REPLAY_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const WatchRecordedGame(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<WatchRecordedGame> createState() => _WatchRecordedGameState();
}

class _WatchRecordedGameState extends State<WatchRecordedGame> {
  final GameManagerService gameManagerService = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Watch Recorded Game'),
            GameRecordDetails(gameRecord: gameManagerService.gameRecord),
            // TODO: implement save account id in the game record
            CustomButton(text: 'Sauvegarder la reprise vidéo', press: () {}),
            TimelineWidget(),
          ],
        ),
      ),
    );
  }
}
