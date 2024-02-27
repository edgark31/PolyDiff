import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const routeName = DASHBOARD_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => DashboardPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomMenuDrawer(),
      appBar: AppBar(
        backgroundColor: kMidOrange,
        title: const Text('R A C C O O N  V I L L A G E'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _navigateTo(DASHBOARD_ROUTE),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _navigateTo(SEARCH_ROUTE),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _navigateTo(PROFILE_ROUTE),
          ),
        ],
      ),
    );
  }
}
