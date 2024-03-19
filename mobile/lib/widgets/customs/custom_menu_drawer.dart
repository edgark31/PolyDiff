import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/customs/custom_circle_avatar.dart';
import 'package:provider/provider.dart';

class CustomMenuDrawer extends StatefulWidget {
  const CustomMenuDrawer({super.key});

  @override
  _CustomMenuDrawerState createState() => _CustomMenuDrawerState();
}

class _CustomMenuDrawerState extends State<CustomMenuDrawer> {
  late final AvatarProvider _avatarProvider;
  late final InfoService _infoService;
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    // Initialize providers in initState to avoid calling Provider.of in build method

    _avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    _infoService = Provider.of<InfoService>(context, listen: false);
    _socketService = Provider.of<SocketService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to AvatarProvider changes

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_infoService.username),
            accountEmail: Text(_infoService.email),
            currentAccountPicture: CustomCircleAvatar(
              // Provide a unique key to force widget rebuild when avatar changes
              key: ValueKey(AvatarProvider.instance.currentAvatarUrl),

              imageUrl: _avatarProvider.currentAvatarUrl,
            ),
            decoration: BoxDecoration(color: kMidOrange),
          ),
          ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () => Navigator.pushNamed(context, PROFILE_ROUTE)),
          SizedBox(height: 10),
          ListTile(
              leading: Icon(Icons.message_rounded),
              title: Text('Message'),
              onTap: () => Navigator.pushNamed(context, CHAT_ROUTE)),
          SizedBox(height: 10),
          ListTile(
              leading: Icon(Icons.line_axis),
              title: Text('Statistiques'),
              onTap: () => Navigator.pushNamed(context, PROFILE_ROUTE)),
          SizedBox(height: 10),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text('Réglages'),
              onTap: () => Navigator.pushNamed(context, SETTINGS_ROUTE)),
          SizedBox(height: 10),
          Divider(),
          ListTile(
              leading: Icon(Icons.lock_person_rounded),
              title: Text('Admin'),
              onTap: () => Navigator.pushNamed(context, ADMIN_ROUTE)),
          SizedBox(height: 10),
          ListTile(
              leading: Icon(
                Icons.logout,
              ),
              title: Text('Déconnexion'),
              onTap: () {
                print('Déconnexion');
                _socketService.disconnect(SocketType.Auth);
                Navigator.pushNamed(context, HOME_ROUTE);
              }),
        ],
      ),
    );
  }
}
