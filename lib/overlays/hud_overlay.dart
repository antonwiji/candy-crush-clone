import 'package:flutter/material.dart';

import '../game/game_snapshot.dart';
import '../game/sweet_match_game.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({required this.game, super.key});

  final SweetMatchGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<GameSnapshot>(
        valueListenable: game.stats,
        builder: (context, snapshot, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _StatChip(title: 'SCORE', value: '${snapshot.score}'),
                    const SizedBox(width: 8),
                    _StatChip(title: 'MOVES', value: '${snapshot.moves}'),
                    const Spacer(),
                    IconButton.filledTonal(
                      onPressed: game.pauseGame,
                      icon: const Icon(Icons.pause_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  '${snapshot.levelName}  |  ${snapshot.target}',
                  style: const TextStyle(
                    color: Color(0xff70365a),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (snapshot.message.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    snapshot.message,
                    style: const TextStyle(
                      color: Color(0xffef5795),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(224),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xffb27b91))),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xff70365a))),
        ],
      ),
    );
  }
}
