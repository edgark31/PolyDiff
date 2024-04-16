import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_menu_drawer.dart';
import 'package:mobile/widgets/friends_list.dart';
import 'package:mobile/widgets/friends_pending.dart';
import 'package:mobile/widgets/friends_search.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  static const routeName = FRIENDS_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => FriendsPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  int _selectedViewIndex = 0;

  final SocketService socketService = Get.find();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        socketService.onlyAuthSocketShouldBeConnected(
            pageName: FRIENDS_ROUTE);
      }
    });
    super.initState();
  }

  void _selectView(int index) {
    setState(() {
      _selectedViewIndex = index;
    });
  }

  Widget _buildContent() {
    switch (_selectedViewIndex) {
      case 0:
        return FriendsList();
      case 1:
        return FriendsPending();
      case 2:
        return FriendsSearch();

      default:
        return Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();

    return Scaffold(
      drawer: CustomMenuDrawer(),
      appBar:
          CustomAppBar(title: AppLocalizations.of(context)!.friend_pageTitle),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(infoService.isThemeLight
                ? LIMITED_TIME_BACKGROUND_PATH
                : LIMITED_TIME_BACKGROUND_PATH_DARK),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  ElevatedButton(
                    onPressed: () => _selectView(i),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (_selectedViewIndex == i) {
                            return Color.fromARGB(255, 2, 70, 22);
                          } else {
                            return kLightGreen;
                          }
                        },
                      ),
                    ),
                    child: Text(
                        i == 0
                            ? AppLocalizations.of(context)!
                                .friend_allFriendsButton
                            : (i == 1
                                ? AppLocalizations.of(context)!
                                    .friend_pendingButton
                                : AppLocalizations.of(context)!
                                    .friend_addButton),
                        style: TextStyle(fontSize: 25, color: Colors.white)),
                  ),
                ]
              ],
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }
}
