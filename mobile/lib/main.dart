import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/providers/camera_image_provider.dart';
import 'package:mobile/providers/register_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/game_card_service.dart';
import 'package:mobile/services/game_management_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_selection_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/services/sound_service.dart';
import 'package:provider/provider.dart';

Widget defaultHome = HomePage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeServices();

  runApp(MultiProvider(providers: [
    // Services (in order of initializeServices())
    ChangeNotifierProvider(create: (context) {
      SocketService socketService = Get.find();
      return socketService; // No dependencies
    }),
    ChangeNotifierProvider(create: (context) {
      InfoService infoService = Get.find();
      return infoService; // No dependencies
    }),
    ChangeNotifierProvider(create: (context) {
      GameCardService gameCardService = Get.find();
      return gameCardService; // No dependencies
    }),
    ChangeNotifierProvider(create: (context) {
      LobbySelectionService lobbySelectionService = Get.find();
      return lobbySelectionService; // No dependencies
    }),
    ChangeNotifierProvider(create: (context) {
      SoundService soundService = Get.find();
      return soundService; // Depends on InfoService
    }),
    ChangeNotifierProvider(create: (context) {
      GameManagementService gameManagementService = Get.find();
      return gameManagementService; // Depends on SocketService and CaptureGameEventsService
    }),
    ChangeNotifierProvider(create: (context) {
      GameAreaService gameAreaService = Get.find();
      return gameAreaService; // Depends on SocketService, GameManagementService, and SoundService
    }),
    ChangeNotifierProvider(create: (context) {
      LobbyService lobbyService = Get.find();
      return lobbyService; // Depends on SocketService and LobbySelectionService
    }),
    ChangeNotifierProvider(create: (context) {
      GameManagerService gameManagerService = Get.find();
      return gameManagerService; // Depends on SocketService, LobbyService, and GameAreaService
    }),
    ChangeNotifierProvider(create: (context) {
      ChatService chatService = Get.find();
      return chatService; // Depends on LobbyService and SocketService
    }),

    // Providers in order of initializeServices()
    // Avatar
    ChangeNotifierProvider(create: (context) {
      AvatarProvider avatarProvider = Get.find();
      return avatarProvider; // Depends on InfoService
    }),
    ChangeNotifierProvider(create: (context) {
      RegisterProvider registerProvider = Get.find();
      return registerProvider; // Depends on AvatarProvider
    }),
    ChangeNotifierProvider(create: (context) => CameraImageProvider()),

    ChangeNotifierProvider(create: (context) => ThemeProvider()),
  ], child: const MyApp()));
}

void initializeServices() {
  Get.put(SocketService()); // No dependencies
  Get.put(InfoService()); // No dependencies
  Get.put(GameCardService()); // No dependencies
  Get.put(LobbySelectionService()); // No dependencies
  Get.put(SoundService()); // Depends on InfoService
  Get.put(
      GameManagementService()); // Depends on SocketService and CaptureGameEventsService
  Get.put(
      GameAreaService()); // Depends on SocketService, GameManagementService, and SoundService
  Get.put(LobbyService()); // Depends on SocketService and LobbySelectionService
  Get.put(
      GameManagerService()); // Depends on SocketService, LobbyService, and GameAreaService
  Get.put(ChatService()); // Depends on LobbyService and SocketService
  Get.put(AvatarProvider()); // Depends on InfoService
  Get.put(RegisterProvider()); // Depends on AvatarProvider
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME_TXT,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(kLightGreen.value)),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: HomePage.routeName,
    );
  }
}
