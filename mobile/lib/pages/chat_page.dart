import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/socket_service.dart';
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
    final SocketService socketService = Get.find();
    Future.delayed(Duration.zero, () {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        socketService.onlyAuthSocketShouldBeConnected(
            pageName: CHAT_ROUTE);
      }
    });
    return Scaffold(
      drawer: CustomMenuDrawer(),
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.chat_title),
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
