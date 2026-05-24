import 'package:flutter/material.dart';

import '../game/sweet_match_game.dart';
import 'overlay_widgets.dart';

class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({required this.game, super.key});

  final SweetMatchGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffffc6dd), Color(0xffffeec7)],
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(30),
      child: GamePanel(
        child: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sweet', style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Color(0xffef5795))),
              const Text('MATCH', style: TextStyle(fontSize: 25, letterSpacing: 7, fontWeight: FontWeight.bold, color: Color(0xffff9c37))),
              const SizedBox(height: 12),
              Text('Cocokkan suguhan warna-warni!', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 30),
              SweetButton(label: 'PLAY', onPressed: () => game.startGame()),
            ],
          ),
        ),
      ),
    );
  }
}
