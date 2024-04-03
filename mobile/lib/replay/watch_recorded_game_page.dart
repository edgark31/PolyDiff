import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';

class WatchRecordedGame extends StatefulWidget {
  const WatchRecordedGame({super.key});

  static const routeName = VIDEOS_ROUTE;

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
  final GameRecordProvider gameRecordProvider = Get.find();
  final defaultDateForTest = 'Wed, 03 Apr 2024 19:15:01 GMT';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // GameRecordDetails(gameRecord: gameManagerService.gameRecord),
            // TODO: implement save account id in the game record
            CustomButton(
                text: 'ajouter le accountId',
                press: () {
                  gameRecordProvider.addAccountIdByDate(defaultDateForTest);
                }),

            SizedBox(width: 1),

            CustomButton(
                text: 'Supprimer le accountId',
                press: () {
                  gameRecordProvider.deleteAccountIdByDate(defaultDateForTest);
                }),
          ],
        ),
        Row(
          children: [
            CustomButton(
                text: 'fetch one',
                press: () {
                  gameRecordProvider.getByDate(defaultDateForTest);
                }),
          ],
        ),
      ],
    );
  }
}
