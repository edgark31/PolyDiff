import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/widgets/admin_popup.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/stroked_text_widget.dart';
import 'package:mobile/widgets/widgets.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();

    double screenHeight = MediaQuery.of(context).size.height;
    double startingPoint = screenHeight * 0.05;
    return BackgroundContainer(
      backgroundImagePath: infoService.isThemeLight
          ? MENU_BACKGROUND_PATH
          : MENU_BACKGROUND_PATH_DARK,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: CustomMenuDrawer(),
        appBar: CustomAppBar(title: ''),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: startingPoint),
                    child: StrokedTextWidget(
                      text: AppLocalizations.of(context)!.dashboard_welcomeText,
                      textStyle: TextStyle(
                        fontFamily: 'troika',
                        fontSize: 140,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8A430),
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomButton(
                    text: AppLocalizations.of(context)!.dashboard_gameModes,
                    press: () {
                      Navigator.pushNamed(context, GAME_MODES_ROUTE);
                    },
                    widthFactor: 0.30,
                    height: 80,
                    fontSize: 20,
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: "Chat",
                    press: () {
                      Navigator.pushNamed(context, CHAT_ROUTE);
                    },
                    widthFactor: 0.30,
                    height: 80,
                    fontSize: 20,
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: "Admin",
                    press: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return AdminPopup();
                        },
                      );
                    },
                    widthFactor: 0.30,
                    height: 80,
                    fontSize: 20,
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
