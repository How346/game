import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/game_config.dart';
import 'screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock the game to portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(const GridSnapApp());
}

class GridSnapApp extends StatelessWidget {
  const GridSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: GameConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: GameConfig.primaryColor,
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}
