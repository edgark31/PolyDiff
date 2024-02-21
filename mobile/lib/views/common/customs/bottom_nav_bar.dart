import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/pages/dashboard_page.dart';
import 'package:mobile/pages/profile_page.dart';
import 'package:mobile/pages/search_page.dart';
import 'package:mobile/pages/settings_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentIndex = 0;
    });
  }

  void goToPage(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    // home page
    DashboardPage(),

    // search a user page
    SearchPage(),

    // profile page
    ProfilePage(),

    // application configuration settings page
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: kDarkOrange,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
              backgroundColor: kDarkOrange,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: kMidOrange,
              gap: 8,
              padding: EdgeInsets.all(16),
              onTabChange: (index) => goToPage(index),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
                ),
                GButton(
                  icon: Icons.settings,
                  text: 'Settings',
                ),
              ]),
        ),
      ),
    );
  }
}
