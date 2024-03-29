import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/widgets.dart';

class ChatPage extends StatelessWidget {
  static const routeName = CHAT_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => ChatPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomMenuDrawer(),
      appBar: CustomAppBar(title: 'C L A V A R D A G E'),
      body: BackgroundContainer(
        child: Column(
          children: [
            Expanded(
              child: ChatBox(),
            ),
          ],
        ),
      ),
    );
  }
}
