import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const routeName = DASHBOARD_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const DashboardPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  Widget _gameModeOption(
      String title, IconData icon, String route, Color color) {
    return CustomButton(
      text: title,
      press: () => _navigateTo(route),
      backgroundColor: color,
      icon: icon,
      widthFactor: 0.30,
      height: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      backgroundImagePath: SELECTION_BACKGROUND_PATH,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: CustomMenuDrawer(),
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, bottom: 20.0),
                    child: Text(
                      'SÉLECTIONNER UN MODE DE JEU',
                      style: TextStyle(
                          fontSize: 30,
                          color: kMidOrange,
                          backgroundColor: kLight,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  _gameModeOption('Classique', Icons.class_,
                      CLASSIC_LOBBY_ROUTE, kMidOrange),
                  SizedBox(height: 20), // Spacing between buttons
                  _gameModeOption('Temps Limité', Icons.hourglass_bottom,
                      DASHBOARD_ROUTE, kMidGreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
