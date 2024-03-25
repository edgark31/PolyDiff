// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:mobile/pages/chat_page.dart';
import 'package:mobile/pages/classic_game_page.dart';
import 'package:mobile/pages/create_room_card_page.dart';
import 'package:mobile/pages/create_room_options_page.dart';
import 'package:mobile/pages/dashboard_page.dart';
import 'package:mobile/pages/edit_profile_page.dart';
import 'package:mobile/pages/histoy_page.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:mobile/pages/lobby_page.dart';
import 'package:mobile/pages/lobby_selection_page.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/pages/profile_page.dart';
import 'package:mobile/pages/search_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/pages/signup_page.dart';
import 'package:mobile/pages/statistics_page.dart';

// Important if testing on a real device with a local server
// Change the IP address to your local machine's IP address
// Something like: http://192.168.0.100:3000
// windows command : netsh interface ip show address | findstr "IP Address"

// Change this URL to your local machine's IP address when testing on tablet
// const String BASE_URL = 'http://192.168.0.100:3000'; // Testing on tablet
const String BASE_URL = 'http://34.118.163.79:3000'; // Testing on real server
// const String BASE_URL = 'http://localhost:3000'; // Testing on chrome
const String API_URL = '$BASE_URL/api';

// MAIN PAGES
const String HOME_ROUTE = '/';
const String ERROR_ROUTE = '/error';
const String LOGIN_ROUTE = '/login';
const String SIGN_UP_ROUTE = '/signup';
const String LOGOUT_ROUTE = '/';
const String DASHBOARD_ROUTE = '/dashboard';
const String CHAT_ROUTE = '/chat';

// ACCOUNT/PROFILE
const String ADMIN_ROUTE = '/admin';
const String PROFILE_ROUTE = '/profile';
const String SETTINGS_ROUTE = '$PROFILE_ROUTE/settings';
const String EDIT_PROFILE_ROUTE = '$PROFILE_ROUTE/edit';
const String STATISTICS_ROUTE = '$PROFILE_ROUTE/statistics';
const String HISTORY_ROUTE = '$PROFILE_ROUTE/history';

// FRIENDS
const String FRIENDS_ROUTE = '/friends';
const String SEARCH_FRIEND_ROUTE = '$FRIENDS_ROUTE/search';

// GAMES
const String GAME_ROUTE = '/game';
const String CLASSIC_ROUTE = '$GAME_ROUTE/classic';
const String LIMITED_TIME_ROUTE = '$GAME_ROUTE/limited';

// LOBBY
const String LOBBY_ROUTE = '/lobby';
const String LOBBY_SELECTION_ROUTE = '$LOBBY_ROUTE/selection';
const String CREATE_ROOM_CARD_ROUTE = '/create/card';
const String CREATE_ROOM_OPTIONS_ROUTE = '/create/options';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
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

      case StatisticsPage.routeName:
        return StatisticsPage.route();

      case EditProfilePage.routeName:
        return EditProfilePage.route();

      case SearchPage.routeName:
        return SearchPage.route();

      case SettingsPage.routeName:
        return SettingsPage.route();

      case HistoryPage.routeName:
        return HistoryPage.route();

      case LobbySelectionPage.routeName:
        return LobbySelectionPage.route();

      case LobbyPage.routeName:
        return LobbyPage.route();

      case ChatPage.routeName:
        return ChatPage.route();

      case CreateRoomCardPage.routeName:
        return CreateRoomCardPage.route();

      case CreateRoomOptionsPage.routeName:
        return CreateRoomOptionsPage.route();

      case ClassicGamePage.routeName:
        return ClassicGamePage.route();
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
