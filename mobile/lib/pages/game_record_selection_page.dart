import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/widgets/customs/background_container.dart';
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
  bool _isFetchingGameRecords = false;
  bool isLoading = false;
  String errorMessage = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFetchingGameRecords) {
      _isFetchingGameRecords = true;
      _fetchGameRecords();
    }
  }

  Future<void> _fetchGameRecords() async {
    setState(() => isLoading = true);
    final gameCardProvider =
        Provider.of<GameRecordProvider>(context, listen: false);
    String? serverErrorMessage = await gameCardProvider.findAllByAccountId();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (serverErrorMessage != null) {
          errorMessage = serverErrorMessage;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();

    final GameRecordProvider gameRecordProvider =
        context.watch<GameRecordProvider>();

    if (isLoading) return CircularProgressIndicator();

    return BackgroundContainer(
      backgroundImagePath: infoService.isThemeLight
          ? LIMITED_TIME_BACKGROUND_PATH
          : LIMITED_TIME_BACKGROUND_PATH_DARK,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(title: 'Replays'), // TODO: Translate this
        body: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return GameRecordCardWidget(
                gameRecordCard:
                    GameRecordCard.fromGameRecord(gameRecordProvider.record),
                onReplay: () {
                  // TODO: Add back when replay is implemented
                  // Navigator.pushNamed(context, REPLAY_ROUTE,
                  //     arguments: gameRecordProvider.record);
                },
                onDelete: () => gameRecordProvider
                    .deleteAccountId(gameRecordProvider.record.date));
          },
        ),
      ),
    );
  }
}
