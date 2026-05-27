import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class FloatingScoreComponent extends PositionComponent
    implements OpacityProvider {
  FloatingScoreComponent({
    required this.label,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(170, 42),
          anchor: Anchor.center,
          priority: 100,
        );

  final String label;
  double _opacity = 1;

  @override
  double get opacity => _opacity;

  @override
  set opacity(double value) {
    _opacity = value.clamp(0, 1).toDouble();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      MoveEffect.by(
        Vector2(0, -34),
        EffectController(duration: .68, curve: Curves.easeOutCubic),
      ),
    );
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: .68, curve: Curves.easeIn),
        onComplete: removeFromParent,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w800,
          fontSize: 25,
          color: const Color(0xffd94186).withValues(alpha: _opacity),
          shadows: [
            Shadow(
              color: const Color(0xffffffff).withValues(alpha: _opacity),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset((size.x - painter.width) / 2, (size.y - painter.height) / 2),
    );
  }
}
