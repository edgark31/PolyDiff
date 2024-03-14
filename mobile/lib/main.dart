import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/providers/camera_image_provider.dart';
import 'package:mobile/services/avatar_service.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/game_card_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/lobby_selection_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:provider/provider.dart';

Widget defaultHome = HomePage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeServices();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => CameraImageProvider()),
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
      ChatService chatService = Get.find();
      return chatService;
    }),
    ChangeNotifierProvider(create: (context) {
      GameCardService gameCardService = Get.find();
      return gameCardService;
    }),
    // Avatar
    ChangeNotifierProvider(create: (context) => AvatarProvider()),
    Provider(create: (context) => AvatarService()),
  ], child: const MyApp()));
}

void initializeServices() {
  Get.put(SocketService());
  Get.put(GameAreaService());
  Get.put(InfoService());
  Get.put(LobbySelectionService());
  Get.put(LobbyService());
  Get.put(ChatService());
  Get.put(GameCardService());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolyDiff',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(kLightGreen.value)),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: HomePage.routeName,
    );
  }
}
