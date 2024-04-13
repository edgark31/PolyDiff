import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/game_record_card.dart';
import 'package:provider/provider.dart';

class GameRecordSelectionPage extends StatefulWidget {
  static const String routeName = REPLAYS_SELECTION_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: REPLAYS_SELECTION_ROUTE),
      builder: (_) => GameRecordSelectionPage(),
    );
  }

  @override
  State<GameRecordSelectionPage> createState() =>
      _GameRecordSelectionPageState();
}

class _GameRecordSelectionPageState extends State<GameRecordSelectionPage> {
  final GameRecordProvider gameRecordProvider = Get.find();

  @override
  void initState() {
    super.initState();
    gameRecordProvider.getDefault();
  }

  @override
  Widget build(BuildContext context) {
    final GameRecordProvider gameRecordProvider =
        context.watch<GameRecordProvider>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Replays'),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return GameRecordCardWidget(
              gameRecordCard:
                  GameRecordCard.fromGameRecord(gameRecordProvider.record),
              onReplay: () {
                Navigator.pushNamed(context, REPLAY_ROUTE,
                    arguments: gameRecordProvider.record);
              },
              onDelete: () => gameRecordProvider
                  .deleteAccountId(gameRecordProvider.record.date));
        },
      ),
    );
  }
}
