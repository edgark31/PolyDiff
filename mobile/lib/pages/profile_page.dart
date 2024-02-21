import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage(
                "assets/images/user.jpeg",
              ),
            ),
            const SizedBox(height: 20),
            itemProfile('Cute raccoon', CupertinoIcons.person),
            const SizedBox(height: 20),
            itemProfile('ahadhashmideveloper@gmail.com', CupertinoIcons.mail),
            const SizedBox(height: 20),
            itemProfile('Reprises vidéo', CupertinoIcons.video_camera),
            const SizedBox(height: 20),
            itemProfile('Statistiques', Icons.trending_up),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text('Mettre à jour le profil')),
            )
          ],
        ),
      ),
    );
  }

  itemProfile(String title, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 5),
                color: kMidOrange.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text(title),
        leading: Icon(iconData),
        tileColor: Colors.white,
      ),
    );
  }
}
