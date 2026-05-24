import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/sweet_match_game.dart';
import '../overlays/game_over_overlay.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/level_complete_overlay.dart';
import '../overlays/main_menu_overlay.dart';
import '../overlays/pause_overlay.dart';

class SweetMatchApp extends StatefulWidget {
  const SweetMatchApp({super.key});

  @override
  State<SweetMatchApp> createState() => _SweetMatchAppState();
}

class _SweetMatchAppState extends State<SweetMatchApp> {
  late final SweetMatchGame game = SweetMatchGame();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sweet Match',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffef5795),
          brightness: Brightness.light,
        ),
        fontFamily: 'sans',
      ),
      home: Scaffold(
        body: GameWidget<SweetMatchGame>(
          game: game,
          overlayBuilderMap: {
            SweetMatchGame.mainMenuOverlay: (_, game) => MainMenuOverlay(game: game),
            SweetMatchGame.hudOverlay: (_, game) => HudOverlay(game: game),
            SweetMatchGame.pauseOverlay: (_, game) => PauseOverlay(game: game),
            SweetMatchGame.levelCompleteOverlay: (_, game) =>
                LevelCompleteOverlay(game: game),
            SweetMatchGame.gameOverOverlay: (_, game) => GameOverOverlay(game: game),
          },
          initialActiveOverlays: const [SweetMatchGame.mainMenuOverlay],
        ),
      ),
    );
  }
}
