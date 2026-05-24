import 'package:flutter/material.dart';

import '../game/sweet_match_game.dart';
import 'overlay_widgets.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({required this.game, super.key});

  final SweetMatchGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x55000000),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(42),
      child: GamePanel(
        child: SizedBox(
          width: 245,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Paused', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800)),
              const SizedBox(height: 22),
              SweetButton(label: 'RESUME', onPressed: game.resumeGame),
              const SizedBox(height: 10),
              SweetButton(label: 'RESTART', onPressed: () => game.restartGame(), secondary: true),
              const SizedBox(height: 10),
              SweetButton(label: 'HOME', onPressed: game.returnToMenu, secondary: true),
            ],
          ),
        ),
      ),
    );
  }
}
