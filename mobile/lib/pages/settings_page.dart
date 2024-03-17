import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = SETTINGS_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => SettingsPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
