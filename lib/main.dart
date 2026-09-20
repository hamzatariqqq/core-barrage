import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app/core_barrage_game_screen.dart';
import 'app/home_screen.dart';
import 'app/progression/game_progress.dart';
import 'app/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Full-screen immersive mode
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  // Load saved coins, upgrades and progression
  await GameProgress.instance.load();

  runApp(const CoreBarrageApp());

  // Ads initialize after the app starts so they cannot block startup.
  try {
    await MobileAds.instance.initialize();
  } catch (_) {
    // Game must continue even if ads fail to initialize.
  }
}

class CoreBarrageApp extends StatelessWidget {
  const CoreBarrageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Core Barrage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071119),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF20C6FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: CoreBarrageSplashScreen(
        homeBuilder: (_) => CoreBarrageHomeScreen(
          gameScreenBuilder: (_) => const CoreBarrageGameScreen(),
        ),
      ),
    );
  }
}