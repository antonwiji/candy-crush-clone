import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/audio/audio_manager.dart';
import '../features/economy/domain/game_reward_config.dart';
import '../game/game_snapshot.dart';
import '../game/sweet_match_game.dart';

class LevelCompleteOverlay extends StatefulWidget {
  const LevelCompleteOverlay({required this.game, super.key});

  final SweetMatchGame game;

  @override
  State<LevelCompleteOverlay> createState() => _LevelCompleteOverlayState();
}

class _LevelCompleteOverlayState extends State<LevelCompleteOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _cardController;
  late final List<AnimationController> _starControllers;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _starControllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 430),
      ),
    );
    _cardScale = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );
    _cardOpacity = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );
    unawaited(_runIntro());
  }

  Future<void> _runIntro() async {
    await _cardController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) {
      return;
    }
    unawaited(AudioManager.playWinningSfx());
    for (final controller in _starControllers) {
      await controller.forward();
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) {
        return;
      }
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    for (final controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameSnapshot>(
      valueListenable: widget.game.stats,
      builder: (_, stats, __) {
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(112),
                ),
              ),
            ),
            const Positioned.fill(child: _SparkleField()),
            Center(
              child: FadeTransition(
                opacity: _cardOpacity,
                child: ScaleTransition(
                  scale: _cardScale,
                  child: _WinningCard(
                    stats: stats,
                    starControllers: _starControllers,
                    onNextLevel: widget.game.restartGame,
                    onReplay: widget.game.restartGame,
                    onHome: widget.game.returnToMenu,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WinningCard extends StatelessWidget {
  const _WinningCard({
    required this.stats,
    required this.starControllers,
    required this.onNextLevel,
    required this.onReplay,
    required this.onHome,
  });

  final GameSnapshot stats;
  final List<AnimationController> starControllers;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width - 44, 360.0);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffff8fbc),
              Color(0xffbb88fd),
              Color(0xffffb95a),
            ],
          ),
          border: Border.all(color: Colors.white.withAlpha(165), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x45a33467),
              blurRadius: 30,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _VictoryBadge(),
            const SizedBox(height: 12),
            const Text(
              'Level Complete!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -.6,
                shadows: [
                  Shadow(
                    color: Color(0x66a33467),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Target Reached!',
              style: TextStyle(
                color: Color(0xfffff7dc),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: .3,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _AnimatedStar(controller: starControllers[0], size: 58),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child:
                      _AnimatedStar(controller: starControllers[1], size: 70),
                ),
                const SizedBox(width: 6),
                _AnimatedStar(controller: starControllers[2], size: 58),
              ],
            ),
            const SizedBox(height: 18),
            _ScoreRewardSummary(stats: stats),
            const SizedBox(height: 18),
            _PrimaryCandyButton(label: 'NEXT LEVEL', onPressed: onNextLevel),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SecondaryCandyButton(
                    label: 'REPLAY',
                    onPressed: onReplay,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child:
                      _SecondaryCandyButton(label: 'HOME', onPressed: onHome),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VictoryBadge extends StatelessWidget {
  const _VictoryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xfffff4b7), Color(0xffffb229)],
        ),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55a96c00),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.emoji_events_rounded,
        color: Colors.white,
        size: 39,
        shadows: [
          Shadow(
            color: Color(0x55845400),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _AnimatedStar extends StatelessWidget {
  const _AnimatedStar({required this.controller, required this.size});

  final AnimationController controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1.22), weight: 72),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 1), weight: 28),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    final opacity = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(
        scale: scale,
        child: Icon(
          Icons.star_rounded,
          size: size,
          color: const Color(0xffffd447),
          shadows: const [
            Shadow(
              color: Color(0xaae07e00),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
            Shadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0, -1),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRewardSummary extends StatelessWidget {
  const _ScoreRewardSummary({required this.stats});

  final GameSnapshot stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(58),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(115)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              label: 'SCORE',
              value: '${_format(stats.score)} pts',
              icon: Icons.auto_awesome_rounded,
            ),
          ),
          Container(
            height: 42,
            width: 1,
            color: Colors.white.withAlpha(85),
          ),
          Expanded(
            child: _SummaryTile(
              label: 'REWARD',
              value: '+${GameRewardConfig.winCoinReward} coins',
              icon: Icons.monetization_on_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 23),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(220),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PrimaryCandyButton extends StatelessWidget {
  const _PrimaryCandyButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  void _handlePressed() {
    unawaited(AudioManager.playClickMenuSfx());
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton(
        onPressed: _handlePressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xffa33467),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: Text(label),
      ),
    );
  }
}

class _SecondaryCandyButton extends StatelessWidget {
  const _SecondaryCandyButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  void _handlePressed() {
    unawaited(AudioManager.playClickMenuSfx());
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: _handlePressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withAlpha(190), width: 1.4),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
          shape: const StadiumBorder(),
        ),
        child: Text(label),
      ),
    );
  }
}

class _SparkleField extends StatelessWidget {
  const _SparkleField();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SparklePainter(),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  static const _sparkles = [
    Offset(.13, .20),
    Offset(.82, .18),
    Offset(.18, .72),
    Offset(.78, .76),
    Offset(.50, .16),
    Offset(.88, .50),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(95)
      ..style = PaintingStyle.fill;
    for (final sparkle in _sparkles) {
      final center = Offset(size.width * sparkle.dx, size.height * sparkle.dy);
      final path = Path()
        ..moveTo(center.dx, center.dy - 11)
        ..quadraticBezierTo(
            center.dx + 3, center.dy - 3, center.dx + 11, center.dy)
        ..quadraticBezierTo(
            center.dx + 3, center.dy + 3, center.dx, center.dy + 11)
        ..quadraticBezierTo(
            center.dx - 3, center.dy + 3, center.dx - 11, center.dy)
        ..quadraticBezierTo(
            center.dx - 3, center.dy - 3, center.dx, center.dy - 11);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _format(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
}
