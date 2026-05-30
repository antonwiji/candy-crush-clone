import 'dart:async';

import 'package:flutter/material.dart';

import '../core/audio/audio_manager.dart';

class GamePanel extends StatelessWidget {
  const GamePanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
              color: Color(0x22000000), blurRadius: 22, offset: Offset(0, 10)),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(26), child: child),
    );
  }
}

class SweetButton extends StatelessWidget {
  const SweetButton({
    required this.label,
    required this.onPressed,
    this.secondary = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool secondary;

  void _handlePressed() {
    unawaited(AudioManager.playClickMenuSfx());
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: secondary
          ? OutlinedButton(onPressed: _handlePressed, child: Text(label))
          : FilledButton(onPressed: _handlePressed, child: Text(label)),
    );
  }
}
