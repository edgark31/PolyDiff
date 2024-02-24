import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const routeName = SEARCH_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => SearchPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
