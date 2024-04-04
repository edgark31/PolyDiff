import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/profile_menu.dart';
import 'package:mobile/widgets/widgets.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = context.watch<SocketService>();
    final infoService = context.watch<InfoService>();
    final avatarProvider = context.watch<AvatarProvider>();

    return Scaffold(
      appBar: CustomAppBar(title: "P R O F I L"),
      drawer: CustomMenuDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BackgroundContainer(
              backgroundImagePath: SELECTION_BACKGROUND_PATH,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, EDIT_PROFILE_ROUTE);
                        },
                        child: Stack(
                          children: [
                            Container(
                              key: ValueKey(avatarProvider.currentAvatarUrl),
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                  border: Border.all(width: 4, color: kLight),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: kDark.withOpacity(0.1),
                                    ),
                                  ],
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        avatarProvider.currentAvatarUrl),
                                  )),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 4,
                                    color: kLight,
                                  ),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: kLight,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Column(children: [
                        Text(infoService.username),
                        SizedBox(height: 5),
                        Text(infoService.email),
                      ]),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    // Account information item
                    ProfileMenuWidget(
                        title: "Paramètres",
                        icon: Icons.settings,
                        onPress: () {
                          Navigator.pushNamed(context, EDIT_PROFILE_ROUTE);
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
                        onPress: () {
                          Navigator.pushNamed(context, VIDEOS_ROUTE);
                        }),

                    Divider(),
                    SizedBox(height: 20),
                    ProfileMenuWidget(
                      title: "Déconnexion",
                      icon: Icons.logout_rounded,
                      onPress: () {
                        socketService.disconnect(SocketType.Auth);
                        Navigator.pushNamed(context, HOME_ROUTE);
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
