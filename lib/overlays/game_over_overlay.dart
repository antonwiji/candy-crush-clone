import 'package:flutter/material.dart';

import '../game/game_snapshot.dart';
import '../game/sweet_match_game.dart';
import 'overlay_widgets.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({required this.game, super.key});

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
                const Text('Moves Habis', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xff70365a))),
                const SizedBox(height: 10),
                Text('Score: ${stats.score}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(stats.target, style: const TextStyle(color: Color(0xff9b7084))),
                const SizedBox(height: 22),
                SweetButton(label: 'TRY AGAIN', onPressed: () => game.restartGame()),
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
