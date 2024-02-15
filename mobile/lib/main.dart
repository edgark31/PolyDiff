import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/controllers/camera_image_provider.dart';
import 'package:mobile/controllers/login_provider.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/socket_service.dart';

Widget defaultHome = const HomePage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // TODO : When connexion logic will be done
  // final entrypoint = prefs.getBool('entrypoint') ?? false;
  // final loggedIn = prefs.getBool('loggedIn') ?? false;

  // if (entrypoint & !loggedIn) {
  //   defaultHome = const LoginPage();
  // } else if (entrypoint && loggedIn) {
  //   defaultHome = const HomePage();
  // }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => LoginNotifier()),
    ChangeNotifierProvider(create: (context) => CameraImageUploader()),
    ChangeNotifierProvider(create: (context) => SocketService()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: (context, child) {
      return GetMaterialApp(
        title: 'PolyDiff',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color(kLightGreen.value)),
        ),
        home: HomePage(),
      );
    });
  }
}
