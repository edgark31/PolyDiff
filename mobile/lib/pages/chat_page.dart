import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/chat_box.dart';
import 'package:mobile/widgets/top_nav_bar.dart';

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
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(MENU_BACKGROUND_PATH),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            TopNavBar(),
            Expanded(
              child: ChatBox(),
            ),
          ],
        ),
      ),
    );
  }
}
