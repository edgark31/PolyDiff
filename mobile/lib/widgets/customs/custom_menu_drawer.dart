import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/avatar.dart';

class CustomMenuDrawer extends StatelessWidget {
  const CustomMenuDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Marie-Jade'),
            accountEmail: Text('marie-jade.marcil@polymtl.ca'),
            currentAccountPicture: Avatar(
              imageUrl: 'assets/images/hallelujaRaccoon.jpeg',
              radius: 20,
            ),
            decoration: BoxDecoration(color: kMidOrange),
          ),
          // TODO: Insert the page routes
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
              onTap: () => print('Réglages')),

          SizedBox(height: 10),
          Divider(),
          ListTile(
              leading: Icon(Icons.lock_person_rounded),
              title: Text('Admin'),
              onTap: () => print('Admin')),
          SizedBox(height: 10),
          ListTile(
              leading: Icon(Icons.logout),
              title: Text('Déconnexion'),
              onTap: () => print('Déconnexion')),
        ],
      ),
    );
  }
}
