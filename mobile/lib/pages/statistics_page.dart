import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_circle_avatar.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  static const routeName = STATISTICS_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => StatisticsPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();
    final AvatarProvider avatarProvider = context.watch<AvatarProvider>();
    final username = infoService.username;
    // TODO: create a statistics service
    final List<StatisticItem> statistics = [
      StatisticItem(
          title: "Nombre de parties jouées",
          value: "100",
          icon: Icons.games_rounded),
      StatisticItem(
          title: "Nombre de parties gagnées",
          value: "50",
          icon: Icons.emoji_events),
      StatisticItem(
          title: "Moyenne de différences trouvées par partie",
          value: "3.5",
          icon: Icons.photo_library_outlined),
      StatisticItem(
          title: "Temps moyen par partie", value: "5m 30s", icon: Icons.timer),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: "Statistiques de $username",
      ),
      body: BackgroundContainer(
        backgroundImagePath: SELECTION_BACKGROUND_PATH,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomCircleAvatar(
                  imageUrl: avatarProvider.currentAvatarUrl,
                ),
              ),
              ...statistics
                  .map((stat) => StatisticCard(statistic: stat))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticItem {
  final String title;
  final String value;
  final IconData icon;

  StatisticItem({required this.title, required this.value, required this.icon});
}

class StatisticCard extends StatelessWidget {
  final StatisticItem statistic;

  const StatisticCard({super.key, required this.statistic});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(statistic.icon, color: kMidOrange),
        title: Text(statistic.title),
        trailing: Text(statistic.value, style: TextStyle(color: kMidOrange)),
      ),
    );
  }
}
