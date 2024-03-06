// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';
import 'package:mobile/pages/create_room_page.dart';
import 'package:mobile/pages/dashboard_page.dart';
import 'package:mobile/pages/game_page.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:mobile/pages/join_room_page.dart';
import 'package:mobile/pages/lobby_page.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/pages/profile_page.dart';
import 'package:mobile/pages/search_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/pages/signup_page.dart';

const String HOME_ROUTE = '/';
const String LOGIN_ROUTE = '/login';
const String SIGNUP_ROUTE = '/signup';
const String LOGOUT_ROUTE = '/';
const String DASHBOARD_ROUTE = '/dashboard';
const String SETTINGS_ROUTE = '/settings';
const String CHAT_ROUTE = '/chat';
const String SEARCH_ROUTE = '/search';
const String PROFILE_ROUTE = '/profile';
const String AVATAR_ROUTE = '/avatar';
const String ADMIN_ROUTE = '/admin';
const String ERROR_ROUTE = '/error';
const String CREATE_ROOM_ROUTE = '/create-room';
const String JOIN_ROOM_ROUTE = 'join-room';
const String LOBBY_ROUTE = '/lobby';
const String GAME_ROUTE = '/game';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    print('the Route is: ${settings.name}');

    switch (settings.name) {
      case '/':
        return HomePage.route();

      case LoginPage.routeName:
        return LoginPage.route();

      case SignUpPage.routeName:
        return SignUpPage.route();

      case DashboardPage.routeName:
        return DashboardPage.route();

      case ProfilePage.routeName:
        return ProfilePage.route();

      case SearchPage.routeName:
        return SearchPage.route();

      case SettingsPage.routeName:
        return SettingsPage.route();

      case LobbyPage.routeName:
        return LobbyPage.route();

      case JoinRoomPage.routeName:
        return JoinRoomPage.route();

      case CreateRoomPage.routeName:
        return CreateRoomPage.route();

      case GamePage.routeName:
        return GamePage.route();

      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Navigation Route Error')),
      ),
      settings: RouteSettings(name: ERROR_ROUTE),
    );
  }
}
