import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/widgets/avatar.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_menu_drawer.dart';
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
    final infoService = context.watch<InfoService>();
    return Scaffold(
      drawer: CustomMenuDrawer(),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BackgroundContainer(
              backgroundImagePath: SELECTION_BACKGROUND_PATH,
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Avatar(
                      imageUrl: 'assets/images/sleepyRaccoon.jpg',
                      radius: 70,
                    ),
                    const SizedBox(height: 20),
                    itemProfile(infoService.name, Icons.person),
                    const SizedBox(height: 20),
                    itemProfile(infoService.email, Icons.mail),
                    const SizedBox(height: 20),
                    itemProfile('Reprises vidéo', Icons.video_collection),
                    const SizedBox(height: 20),
                    itemProfile('Historique de parties jouées', Icons.games),
                    const SizedBox(height: 20),
                    itemProfile('Statistiques', Icons.trending_up),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Text('Personnalisation du profil'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemProfile(String title, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: kMidOrange.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        leading: Icon(iconData),
        tileColor: Colors.white,
      ),
    );
  }
}
