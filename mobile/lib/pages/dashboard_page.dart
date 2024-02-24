import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/views/common/custom_menu_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomMenuDrawer(),
      appBar: AppBar(
        title: const Text('R A C C O O N'),
        backgroundColor: kMidOrange,
      ),
      extendBodyBehindAppBar: true,
      body: ListView(padding: EdgeInsets.zero, children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ]),
    );
  }
}
