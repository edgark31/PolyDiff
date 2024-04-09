import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/admin_popup.dart';
import 'package:mobile/widgets/customs/custom_circle_avatar.dart';
import 'package:provider/provider.dart';

class CustomMenuDrawer extends StatefulWidget {
  const CustomMenuDrawer({super.key});

  @override
  State<CustomMenuDrawer> createState() => _CustomMenuDrawerState();
}

class _CustomMenuDrawerState extends State<CustomMenuDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AvatarProvider avatarProvider = context.watch<AvatarProvider>();
    final InfoService infoService = context.watch<InfoService>();
    final SocketService socketService = context.watch<SocketService>();

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(infoService.username),
            accountEmail: Text(infoService.email),
            currentAccountPicture: CustomCircleAvatar(
              key: ValueKey(avatarProvider.currentAvatarUrl),
              imageUrl: avatarProvider.currentAvatarUrl,
            ),
          ),
          ListTile(
              tileColor: Colors.transparent,
              leading: Icon(Icons.home),
              title: Text(AppLocalizations.of(context)!.customMenuDrawer_home),
              onTap: () => Navigator.pushNamed(context, DASHBOARD_ROUTE)),
          SizedBox(height: 10),
          ListTile(
              tileColor: Colors.transparent,
              leading: Icon(Icons.account_circle),
              title: Text(
                AppLocalizations.of(context)!.customMenuDrawer_profile,
              ),
              onTap: () => Navigator.pushNamed(context, PROFILE_ROUTE)),
          SizedBox(height: 10),
          ListTile(
              tileColor: Colors.transparent,
              leading: Icon(Icons.message_rounded),
              title: Text('Chat'),
              onTap: () => Navigator.pushNamed(context, CHAT_ROUTE)),
          SizedBox(height: 10),
          ListTile(
              tileColor: Colors.transparent,
              leading: Icon(Icons.line_axis),
              title: Text(
                AppLocalizations.of(context)!.customMenuDrawer_statistics,
              ),
              onTap: () => Navigator.pushNamed(context, STATISTICS_ROUTE)),
          SizedBox(height: 10),
          ListTile(
              tileColor: Colors.transparent,
              leading: Icon(Icons.settings),
              title: Text(
                AppLocalizations.of(context)!.customMenuDrawer_settings,
              ),
              onTap: () => Navigator.pushNamed(context, EDIT_PROFILE_ROUTE)),
          SizedBox(height: 10),
          Divider(),
          ListTile(
              tileColor: Colors.transparent,
              leading: Icon(Icons.lock_person_rounded),
              title: Text('Admin'),
              onTap: () => {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AdminPopup();
                      },
                    )
                  }),
          SizedBox(height: 10),
          ListTile(
              tileColor: Colors.transparent,
              leading: Icon(
                Icons.logout,
              ),
              title: Text(AppLocalizations.of(context)!.history_disconnection),
              onTap: () {
                print("Disconnecting from hamburger menu");
                socketService.disconnect(SocketType.Auth);
                Navigator.pushNamed(context, HOME_ROUTE);
              }),
        ],
      ),
    );
  }
}
