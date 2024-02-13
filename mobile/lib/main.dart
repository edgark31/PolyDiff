import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/widgets/camera_screen.dart';
import 'package:provider/provider.dart';

import 'services/socket_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SocketService(),
      child: MaterialApp(
        title: 'PolyDiff',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: LoginPage(),
      ),
    );
  }
}
