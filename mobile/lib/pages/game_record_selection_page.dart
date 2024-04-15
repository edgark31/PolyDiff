import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final GameRecordProvider gameRecordProvider = Get.find();
  late List<GameRecord> gameRecordsFromServer;

  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchGameRecords();
  }

  Future<void> _fetchGameRecords() async {
    setState(() => isLoading = true);
    String? serverErrorMessage = await gameRecordProvider.findAllByAccountId();
    if (mounted) {
      setState(() {
        isLoading = false;
        errorMessage = serverErrorMessage ?? "";
        gameRecordsFromServer = gameRecordProvider.gameRecords;
        gameRecordProvider.isPlaybackFromProfile = true;
        if (serverErrorMessage != null) {
          showErrorDialog(serverErrorMessage);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();
    final gameRecordProvider = context.watch<GameRecordProvider>();

    return BackgroundContainer(
      backgroundImagePath: infoService.isThemeLight
          ? LIMITED_TIME_BACKGROUND_PATH
          : LIMITED_TIME_BACKGROUND_PATH_DARK,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(title: 'Replays'), // TODO: Translate this
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : (gameRecordsFromServer.isEmpty
                // TODO: translate this
                ? Center(child: Text("No game records found."))
                : ListView.builder(
                    itemCount: gameRecordsFromServer.length,
                    itemBuilder: (context, index) {
                      return GameRecordCardWidget(
                        gameRecord: gameRecordsFromServer[index],
                        onReplay: (GameRecord record) {
                          // Your replay logic here
                          gameRecordProvider.currentGameRecord = record;
                          print('Replaying game: ${record.date}');
                          Navigator.pushNamed(context, REPLAY_ROUTE,
                              arguments: record);
                        },
                        onDelete: () {
                          gameRecordProvider.currentGameRecord =
                              gameRecordsFromServer[index];
                          print(
                              'Deleting game: ${gameRecordsFromServer[index].date}');
                          gameRecordProvider.deleteAccountId(
                              gameRecordsFromServer[index].date);
                        },
                      );
                    },
                  )),
      ),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // TODO: translate this
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
