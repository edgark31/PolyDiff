import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/providers/camera_image_provider.dart';
import 'package:mobile/providers/register_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/friend_service.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/game_card_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_selection_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/utils/theme_utils.dart';
import 'package:provider/provider.dart';

Widget defaultHome = HomePage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeServices();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => CameraImageProvider()),
    ChangeNotifierProvider(create: (context) {
      RegisterProvider registerProvider = Get.find();
      return registerProvider;
    }),
    ChangeNotifierProvider(create: (context) {
      SocketService socketService = Get.find();
      return socketService;
    }),
    ChangeNotifierProvider(create: (context) {
      GameAreaService gameAreaService = Get.find();
      return gameAreaService;
    }),
    ChangeNotifierProvider(create: (context) {
      InfoService infoService = Get.find();
      return infoService;
    }),

    ChangeNotifierProvider(create: (context) {
      LobbySelectionService lobbySelectionService = Get.find();
      return lobbySelectionService;
    }),
    ChangeNotifierProvider(create: (context) {
      LobbyService lobbyService = Get.find();
      return lobbyService;
    }),
    ChangeNotifierProvider(create: (context) {
      GameManagerService gameManagerService = Get.find();
      return gameManagerService;
    }),
    ChangeNotifierProvider(create: (context) {
      ChatService chatService = Get.find();
      return chatService;
    }),
    ChangeNotifierProvider(create: (context) {
      GameCardService gameCardService = Get.find();
      return gameCardService;
    }),
    ChangeNotifierProvider(create: (context) {
      FriendService friendService = Get.find();
      return friendService;
    }),
    // Avatar
    ChangeNotifierProvider(create: (context) {
      AvatarProvider avatarProvider = Get.find();
      return avatarProvider;
    }),
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
  ], child: const MyApp()));
}

void initializeServices() {
  Get.put(SocketService());
  Get.put(GameAreaService());
  Get.put(InfoService());
  Get.put(LobbySelectionService());
  Get.put(LobbyService());
  Get.put(GameManagerService());
  Get.put(ChatService());
  Get.put(GameCardService());
  Get.put(FriendService());
  Get.put(AvatarProvider());
  Get.put(RegisterProvider());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: APP_NAME_TXT,
      themeMode: ThemeMode.system,
      theme: ThemeClass.darkTheme, // TODO Change according to settings
      // darkTheme: ThemeClass.darkTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: HomePage.routeName,
    );
  }
}
