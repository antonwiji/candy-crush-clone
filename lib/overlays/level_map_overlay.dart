import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/audio/audio_manager.dart';
import '../features/level/models/level_map_item.dart';
import '../game/sweet_match_game.dart';

const _primary = Color(0xffa33467);
const _primaryHot = Color(0xffb72d75);
const _primaryDark = Color(0xff7d0050);
const _gold = Color(0xffeba526);
const _softText = Color(0xff4c3b42);
const _lockedText = Color(0xff92868c);

class LevelMapOverlay extends StatefulWidget {
  const LevelMapOverlay({required this.game, super.key});

  final SweetMatchGame game;

  @override
  State<LevelMapOverlay> createState() => _LevelMapOverlayState();
}

class _LevelMapOverlayState extends State<LevelMapOverlay> {
  late final Future<int> _coinTotal = widget.game.loadCoinTotal();

  static const List<LevelMapItem> _levels = [
    LevelMapItem(
      level: 1,
      status: LevelStatus.completed,
      stars: 3,
      targetScore: 1000,
    ),
    LevelMapItem(
      level: 2,
      status: LevelStatus.completed,
      stars: 2,
      targetScore: 1200,
    ),
    LevelMapItem(
      level: 3,
      status: LevelStatus.current,
      targetScore: 1500,
    ),
    LevelMapItem(
      level: 4,
      status: LevelStatus.unlocked,
      targetScore: 1800,
    ),
    LevelMapItem(level: 5, status: LevelStatus.locked, targetScore: 2100),
    LevelMapItem(level: 6, status: LevelStatus.locked, targetScore: 2400),
    LevelMapItem(level: 7, status: LevelStatus.locked, targetScore: 2700),
    LevelMapItem(level: 8, status: LevelStatus.locked, targetScore: 3000),
    LevelMapItem(level: 9, status: LevelStatus.locked, targetScore: 3400),
    LevelMapItem(level: 10, status: LevelStatus.locked, targetScore: 3800),
  ];

  void _openLevel(LevelMapItem level) {
    unawaited(AudioManager.playClickMenuSfx());
    if (level.isLocked) {
      _showLockedDialog(level.level);
      return;
    }
    unawaited(widget.game.startGame());
  }

  void _goHome() {
    unawaited(AudioManager.playClickMenuSfx());
    widget.game.returnToMenu();
  }

  void _showComingSoon(String title) {
    unawaited(AudioManager.playClickMenuSfx());
    showDialog<void>(
      context: context,
      builder: (context) => _CandyDialog(
        title: title,
        message: 'Coming soon. Fitur ini siap disambungkan nanti.',
      ),
    );
  }

  void _showLockedDialog(int level) {
    showDialog<void>(
      context: context,
      builder: (context) => _CandyDialog(
        title: 'Level $level Locked',
        message: 'Selesaikan level sebelumnya untuk membuka level ini.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _coinTotal,
      builder: (context, snapshot) {
        final coins = snapshot.data ?? 0;
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              const Positioned.fill(child: _MapBackground()),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
                      child: _MapTopBar(
                        coins: coins,
                        onAddCoin: () => _showComingSoon('Shop'),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _LevelPath(
                            levels: _levels,
                            width: constraints.maxWidth,
                            onLevelTap: _openLevel,
                          );
                        },
                      ),
                    ),
                    _MapBottomNavigation(
                      onHome: _goHome,
                      onMap: () => unawaited(AudioManager.playClickMenuSfx()),
                      onSettings: () => _showComingSoon('Settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xfffff4fa),
            Color(0xfffdeaf4),
            Color(0xfff8f2ff),
            Color(0xfffff7f0),
          ],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            left: -26,
            top: 112,
            child: _BlurBubble(icon: Icons.favorite_rounded),
          ),
          Positioned(
            right: -18,
            top: 286,
            child: _BlurBubble(icon: Icons.cake_rounded, warm: true),
          ),
          Positioned(
            left: 110,
            bottom: 186,
            child: _SoftBlob(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 172,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00ffffff), Color(0xf7ffffff)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapTopBar extends StatelessWidget {
  const _MapTopBar({required this.coins, required this.onAddCoin});

  final int coins;
  final VoidCallback onAddCoin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(244),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x18a33467),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.map_rounded, color: _primaryHot, size: 30),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'MAP',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _CoinPill(coins: coins, onAddCoin: onAddCoin),
      ],
    );
  }
}

class _LevelPath extends StatelessWidget {
  const _LevelPath({
    required this.levels,
    required this.width,
    required this.onLevelTap,
  });

  final List<LevelMapItem> levels;
  final double width;
  final ValueChanged<LevelMapItem> onLevelTap;

  @override
  Widget build(BuildContext context) {
    final nodeSize = math.min<double>(width * .22, 88);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 34),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final slot = index % 4;
        final alignment = switch (slot) {
          0 => Alignment.centerLeft,
          1 => Alignment.center,
          2 => Alignment.centerRight,
          _ => Alignment.center,
        };
        final showConnector = index < levels.length - 1;
        return SizedBox(
          height: nodeSize + 112,
          child: Stack(
            children: [
              if (showConnector)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathConnectorPainter(
                      from: alignment,
                      to: _alignmentForIndex(index + 1),
                    ),
                  ),
                ),
              Align(
                alignment: alignment,
                child: _LevelNode(
                  level: level,
                  size: nodeSize,
                  onTap: () => onLevelTap(level),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Alignment _alignmentForIndex(int index) {
    return switch (index % 4) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      2 => Alignment.centerRight,
      _ => Alignment.center,
    };
  }
}

class _PathConnectorPainter extends CustomPainter {
  const _PathConnectorPainter({required this.from, required this.to});

  final Alignment from;
  final Alignment to;

  @override
  void paint(Canvas canvas, Size size) {
    final start = _pointFor(from, size).translate(0, 34);
    final end = _pointFor(to, size).translate(0, size.height - 18);
    final controlY = (start.dy + end.dy) / 2;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(start.dx, controlY, end.dx, controlY, end.dx, end.dy);
    final shadow = Paint()
      ..color = const Color(0x22a33467)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    final paint = Paint()
      ..color = Colors.white.withAlpha(210)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final dashPaint = Paint()
      ..color = const Color(0xffff99c4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
    _drawDashedPath(canvas, path, dashPaint);
  }

  Offset _pointFor(Alignment alignment, Size size) {
    final x = switch (alignment.x) {
      -1 => 46.0,
      0 => size.width / 2,
      _ => size.width - 46,
    };
    return Offset(x, 0);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + 10);
        canvas.drawPath(segment, paint);
        distance += 22;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathConnectorPainter oldDelegate) {
    return oldDelegate.from != from || oldDelegate.to != to;
  }
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.level,
    required this.size,
    required this.onTap,
  });

  final LevelMapItem level;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCurrent = level.status == LevelStatus.current;
    final nodeSize = isCurrent ? size + 10 : size;
    return _PressableScale(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isCurrent)
                Container(
                  width: nodeSize + 18,
                  height: nodeSize + 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffffb8d4).withAlpha(110),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44ff7eb3),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              Container(
                width: nodeSize,
                height: nodeSize,
                decoration: _nodeDecoration(level),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 16,
                      right: 16,
                      height: 18,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withAlpha(
                            level.isLocked ? 70 : 86,
                          ),
                        ),
                      ),
                    ),
                    Center(child: _NodeContent(level: level)),
                  ],
                ),
              ),
              if (level.status == LevelStatus.completed)
                Positioned(
                  right: -3,
                  top: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff60bf72),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              if (isCurrent)
                Positioned(
                  bottom: -15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryDark,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22a33467),
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Text(
                      'CURRENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _StarRow(stars: level.stars, muted: level.isLocked),
          const SizedBox(height: 4),
          Text(
            level.targetScore > 0 ? '${_format(level.targetScore)} pts' : '',
            style: TextStyle(
              color: level.isLocked ? _lockedText : _softText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _nodeDecoration(LevelMapItem level) {
    final colors = switch (level.status) {
      LevelStatus.completed => const [Color(0xffff8fc0), Color(0xffa33467)],
      LevelStatus.current => const [Color(0xffffa8cc), Color(0xffb72d75)],
      LevelStatus.unlocked => const [Color(0xffffffff), Color(0xffffe2ef)],
      LevelStatus.locked => const [Color(0xfff4f0f3), Color(0xffd9d2d7)],
    };
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ),
      border: Border.all(color: Colors.white, width: 4),
      boxShadow: [
        BoxShadow(
          color: level.isLocked
              ? const Color(0x16000000)
              : const Color(0x28a33467),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
        if (!level.isLocked)
          const BoxShadow(
            color: Color(0xffffffff),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
      ],
    );
  }
}

class _NodeContent extends StatelessWidget {
  const _NodeContent({required this.level});

  final LevelMapItem level;

  @override
  Widget build(BuildContext context) {
    if (level.isLocked) {
      return const Icon(Icons.lock_rounded, color: _lockedText, size: 33);
    }
    final textColor =
        level.status == LevelStatus.unlocked ? _primary : Colors.white;
    return Text(
      '${level.level}',
      style: TextStyle(
        color: textColor,
        fontSize: 31,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.stars, required this.muted});

  final int stars;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final active = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            Icons.star_rounded,
            color: active
                ? _gold
                : muted
                    ? const Color(0xffd0c9cd)
                    : const Color(0xffffd9e8),
            size: 20,
            shadows: active
                ? const [
                    Shadow(
                      color: Color(0x28000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _MapBottomNavigation extends StatelessWidget {
  const _MapBottomNavigation({
    required this.onHome,
    required this.onMap,
    required this.onSettings,
  });

  final VoidCallback onHome;
  final VoidCallback onMap;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(38, 15, 38, 18),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(238),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 22,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomNavItem(
            label: 'HOME',
            icon: Icons.home_rounded,
            active: false,
            onTap: onHome,
          ),
          _BottomNavItem(
            label: 'MAP',
            icon: Icons.map_rounded,
            active: true,
            onTap: onMap,
          ),
          _BottomNavItem(
            label: 'SETTINGS',
            icon: Icons.settings_rounded,
            active: false,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = active
        ? Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: _primaryHot,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x34a33467),
                  blurRadius: 12,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            width: 78,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xff9d9298), size: 30),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xff9d9298),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          );

    return _PressableScale(onTap: onTap, child: content);
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.coins, required this.onAddCoin});

  final int coins;
  final VoidCallback onAddCoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(12, 6, 7, 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(245),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1aa33467),
            blurRadius: 15,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _gold,
            ),
            child: const Icon(
              Icons.attach_money_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            _format(coins),
            style: const TextStyle(
              color: Color(0xff191c1d),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -.3,
            ),
          ),
          const SizedBox(width: 9),
          _PressableScale(
            onTap: onAddCoin,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _primary, width: 3),
              ),
              child: const Icon(Icons.add_rounded, color: _primary, size: 23),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandyDialog extends StatelessWidget {
  const _CandyDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            unawaited(AudioManager.playClickMenuSfx());
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _BlurBubble extends StatelessWidget {
  const _BlurBubble({required this.icon, this.warm = false});

  final IconData icon;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        width: 118,
        height: 118,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: warm
              ? const Color(0xffffdca7).withAlpha(140)
              : const Color(0xffff9ccb).withAlpha(120),
        ),
        child: Icon(
          icon,
          color: const Color(0xff8f7780).withAlpha(92),
          size: 38,
        ),
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob();

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        width: 92,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xffd8b9ff).withAlpha(120),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? .96 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

String _format(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
}
