import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/audio/audio_manager.dart';
import '../game/sweet_match_game.dart';
import '../overlays/game_over_overlay.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/level_complete_overlay.dart';
import '../overlays/level_map_overlay.dart';
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
  void initState() {
    super.initState();
    unawaited(AudioManager.playGlobalBgm());
  }

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
        fontFamily: 'Quicksand',
      ),
      home: Scaffold(
        body: GameWidget<SweetMatchGame>(
          game: game,
          overlayBuilderMap: {
            SweetMatchGame.mainMenuOverlay: (_, game) =>
                MainMenuOverlay(game: game),
            SweetMatchGame.levelMapOverlay: (_, game) =>
                LevelMapOverlay(game: game),
            SweetMatchGame.hudOverlay: (_, game) => HudOverlay(game: game),
            SweetMatchGame.pauseOverlay: (_, game) => PauseOverlay(game: game),
            SweetMatchGame.levelCompleteOverlay: (_, game) =>
                LevelCompleteOverlay(game: game),
            SweetMatchGame.gameOverOverlay: (_, game) =>
                GameOverOverlay(game: game),
          },
          initialActiveOverlays: const [SweetMatchGame.mainMenuOverlay],
        ),
      ),
    );
  }
}
