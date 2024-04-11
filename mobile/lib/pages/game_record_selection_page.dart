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
  final GameRecordProvider _gameRecordProvider = Get.find();

  @override
  void initState() {
    super.initState();
    _gameRecordProvider.findAllByAccountId();
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
          final gameRecord = gameRecordProvider.record;
          return GameRecordCardWidget(
              gameRecordCard: GameRecordCard.fromGameRecord(gameRecord),
              onReplay: () {
                Navigator.pushNamed(context, REPLAY_ROUTE);
              },
              onDelete: () =>
                  gameRecordProvider.deleteAccountId(gameRecord.date));
        },
      ),
    );
  }
}
