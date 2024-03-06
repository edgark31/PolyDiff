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

  Widget _gameModeOption(String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => _navigateTo(route),
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 80),
            Text(title, style: TextStyle(fontSize: 22)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'Rejoindre une salle',
                  press: () => Navigator.pushNamed(context, DASHBOARD_ROUTE),
                  backgroundColor: kMidGreen,
                ),
                SizedBox(width: 10),
                CustomButton(
                  text: 'Créer une salle',
                  press: () => Navigator.pushNamed(context, DASHBOARD_ROUTE),
                  backgroundColor: kMidOrange,
                ),
              ],
            ),
          ],
        ),
      ),
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Text(
                  'Sélectionnez le mode de jeu',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  padding: const EdgeInsets.all(30.0),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: <Widget>[
                    _gameModeOption(
                        'Mode Classique', Icons.class_, DASHBOARD_ROUTE),
                    _gameModeOption('Mode Temps Limité', Icons.hourglass_bottom,
                        DASHBOARD_ROUTE),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
