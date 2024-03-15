import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/avatar.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/profile_menu.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const routeName = PROFILE_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const ProfilePage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final socketService = context.watch<SocketService>();
    final infoService = context.watch<InfoService>();

    // avatar
    AvatarProvider.instance.setAccountAvatarUrl(infoService.username);
    final avatarUrl = AvatarProvider.instance.currentAvatarUrl;

    return Scaffold(
      appBar: CustomAppBar(title: "P R O F I L"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BackgroundContainer(
              backgroundImagePath: SELECTION_BACKGROUND_PATH,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Avatar(
                      imageUrl: avatarUrl,
                      radius: 70,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Text(infoService.username),
                          SizedBox(height: 5),
                          Text(infoService.email),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      child: CustomButton(
                          text: "Modifier votre profil",
                          press: () {
                            Navigator.pushNamed(context, EDIT_PROFILE_ROUTE);
                          },
                          backgroundColor: kMidOrange),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Account information item
                    ProfileMenuWidget(
                        title: "Réglages",
                        icon: Icons.settings,
                        onPress: () {
                          Navigator.pushNamed(context, SETTINGS_ROUTE);
                        }),
                    SizedBox(height: 10),
                    ProfileMenuWidget(
                        title: "Historique",
                        icon: Icons.games,
                        onPress: () {
                          Navigator.pushNamed(context, HISTORY_ROUTE);
                        }),
                    SizedBox(height: 10),
                    ProfileMenuWidget(
                        title: "Statistiques",
                        icon: Icons.trending_up,
                        onPress: () {
                          Navigator.pushNamed(context, STATISTICS_ROUTE);
                        }),
                    SizedBox(height: 10),
                    ProfileMenuWidget(
                        title: "Reprises vidéos",
                        icon: Icons.video_collection,
                        onPress: () => {}),

                    Divider(),
                    SizedBox(height: 20),
                    ProfileMenuWidget(
                      title: "Déconnexion",
                      icon: Icons.logout_rounded,
                      onPress: () {
                        socketService.logOut(context, SocketType.Auth);
                      },
                      endIcon: false,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
