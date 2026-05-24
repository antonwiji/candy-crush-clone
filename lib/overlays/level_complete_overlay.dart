import 'package:flutter/material.dart';

import '../game/game_snapshot.dart';
import '../game/sweet_match_game.dart';
import 'overlay_widgets.dart';

class LevelCompleteOverlay extends StatelessWidget {
  const LevelCompleteOverlay({required this.game, super.key});

  final SweetMatchGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x66000000),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(38),
      child: ValueListenableBuilder<GameSnapshot>(
        valueListenable: game.stats,
        builder: (_, stats, __) => GamePanel(
          child: SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Level Complete!', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Color(0xffef5795))),
                const SizedBox(height: 8),
                const Text('***', style: TextStyle(fontSize: 30, letterSpacing: 10, color: Color(0xffffc62e))),
                Text('Score: ${stats.score}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 22),
                SweetButton(label: 'PLAY AGAIN', onPressed: () => game.restartGame()),
                const SizedBox(height: 10),
                SweetButton(label: 'HOME', onPressed: game.returnToMenu, secondary: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
