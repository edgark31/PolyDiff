// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';

class ClassicGamePage extends StatefulWidget {
  static const routeName = CLASSIC_ROUTE;
  ClassicGamePage();

  @override
  State<ClassicGamePage> createState() => _ClassicGamePageState();

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => ClassicGamePage(),
      settings: RouteSettings(name: routeName),
    );
  }
}

class _ClassicGamePageState extends State<ClassicGamePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Partie classique';
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Row(
            children: [Text('Clock')],
          ),
          SizedBox(height: 10),
          AbsorbPointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //ModifiedCanvas(images, '123'),
                SizedBox(width: 50),
                //OriginalCanvas(images, '123'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
