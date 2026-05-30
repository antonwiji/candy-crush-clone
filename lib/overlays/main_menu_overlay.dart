import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/audio/audio_manager.dart';
import '../features/level/domain/level_progress.dart';
import '../game/sweet_match_game.dart';

const _primary = Color(0xffa33467);
const _primaryHot = Color(0xffb72d75);
const _primaryDark = Color(0xff7d0050);
const _secondary = Color(0xff7644b5);
const _tertiary = Color(0xffa06100);
const _gold = Color(0xffeba526);
const _softText = Color(0xff4c3b42);

class MainMenuOverlay extends StatefulWidget {
  const MainMenuOverlay({required this.game, super.key});

  final SweetMatchGame game;

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  late final Future<_MainMenuData> _menuData = _loadMenuData();

  Future<_MainMenuData> _loadMenuData() async {
    final results = await Future.wait<Object>([
      widget.game.loadCoinTotal(),
      widget.game.loadLevelProgress(),
    ]);
    return _MainMenuData(
      coins: results[0] as int,
      progress: results[1] as LevelProgress,
    );
  }

  void _play() {
    unawaited(AudioManager.playClickMenuSfx());
    unawaited(widget.game.startGame());
  }

  void _openMap() {
    unawaited(AudioManager.playClickMenuSfx());
    widget.game.showLevelMap();
  }

  void _showComingSoon(String title) {
    unawaited(AudioManager.playClickMenuSfx());
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title),
        content: const Text('Coming soon. Fitur ini siap disambungkan nanti.'),
        actions: [
          TextButton(
            onPressed: () {
              unawaited(AudioManager.playClickMenuSfx());
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MainMenuData>(
      future: _menuData,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final coins = data?.coins ?? 0;
        final currentLevel = data?.progress.currentLevel ?? 1;
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              const Positioned.fill(child: _HomeBackground()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 740;
                    final cardWidth = math.min<double>(
                      constraints.maxWidth * .62,
                      compact ? 230 : 260,
                    );
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: _CoinPill(
                              coins: coins,
                              onAddCoin: () => _showComingSoon('Shop'),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 26 : 56),
                        _LevelPreviewCard(
                          level: currentLevel,
                          width: cardWidth,
                        ),
                        SizedBox(height: compact ? 28 : 44),
                        _PlayButton(onPressed: _play),
                        SizedBox(height: compact ? 28 : 40),
                        _ShortcutMenu(
                          onDaily: () => _showComingSoon('Daily Reward'),
                          onShop: () => _showComingSoon('Shop'),
                          onSettings: () => _showComingSoon('Settings'),
                        ),
                        const Spacer(),
                        _HomeBottomNavigation(
                          onHome: () =>
                              unawaited(AudioManager.playClickMenuSfx()),
                          onMap: _openMap,
                          onSettings: () => _showComingSoon('Settings'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MainMenuData {
  const _MainMenuData({required this.coins, required this.progress});

  final int coins;
  final LevelProgress progress;
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

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
              left: 34, top: 132, child: _BlurBubble(icon: Icons.cake_rounded)),
          Positioned(
              right: -18,
              top: 360,
              child:
                  _BlurBubble(icon: Icons.rocket_launch_rounded, warm: true)),
          Positioned(left: 98, top: 650, child: _SoftBlob()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 170,
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
              color: Color(0x1aa33467), blurRadius: 15, offset: Offset(0, 7)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: _gold),
            child: const Icon(Icons.attach_money_rounded,
                color: Colors.white, size: 21),
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

class _LevelPreviewCard extends StatelessWidget {
  const _LevelPreviewCard({required this.level, required this.width});

  final int level;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(44),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x19a33467),
                    blurRadius: 24,
                    offset: Offset(0, 13)),
                BoxShadow(
                    color: Color(0xffffffff),
                    blurRadius: 2,
                    offset: Offset(0, -1)),
              ],
            ),
            child: AspectRatio(
              aspectRatio: .98,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xffffd7e3), Color(0xfffff0e0)],
                  ),
                ),
                child: const _CandyThumbnail(),
              ),
            ),
          ),
          Positioned(
            bottom: -42,
            child: Container(
              width: width * .88,
              height: 74,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(38),
                border: Border.all(color: const Color(0xffffe5f0), width: 3),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x16a33467),
                      blurRadius: 14,
                      offset: Offset(0, 9)),
                ],
              ),
              child: Text(
                'LEVEL $level',
                style: const TextStyle(
                  color: _primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandyThumbnail extends StatelessWidget {
  const _CandyThumbnail();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CandyPainter());
  }
}

class _CandyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadow = Paint()
      ..color = const Color(0x22a33467)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .50, size.height * .72),
        width: size.width * .58,
        height: size.height * .13,
      ),
      shadow,
    );

    _drawLollipop(canvas, size, Offset(size.width * .50, size.height * .43),
        size.width * .24, const Color(0xffff7a48));
    _drawLollipop(canvas, size, Offset(size.width * .31, size.height * .46),
        size.width * .13, const Color(0xffff7c88));
    _drawLollipop(canvas, size, Offset(size.width * .70, size.height * .38),
        size.width * .10, const Color(0xff70d7d0));

    final stickPaint = Paint()
      ..color = const Color(0xff9a5ecb)
      ..strokeWidth = size.width * .04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .72, size.height * .66),
      Offset(size.width * .83, size.height * .34),
      stickPaint,
    );
    final stripePaint = Paint()
      ..color = Colors.white.withAlpha(220)
      ..strokeWidth = size.width * .016
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (.38 + i * .07);
      canvas.drawLine(
        Offset(size.width * .77, y),
        Offset(size.width * .84, y + size.height * .05),
        stripePaint,
      );
    }

    for (final candy in [
      (Offset(.31, .67), const Color(0xff8fd331)),
      (Offset(.40, .70), const Color(0xffffc62e)),
      (Offset(.50, .72), const Color(0xfff34f91)),
      (Offset(.60, .69), const Color(0xffffc62e)),
      (Offset(.69, .66), const Color(0xff8458bd)),
      (Offset(.45, .62), const Color(0xff8458bd)),
      (Offset(.56, .61), const Color(0xffff8d2f)),
    ]) {
      final center =
          Offset(size.width * candy.$1.dx, size.height * candy.$1.dy);
      final paint = Paint()..color = candy.$2;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: size.width * .11,
          height: size.width * .075,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(-size.width * .02, -size.width * .018),
          width: size.width * .035,
          height: size.width * .015,
        ),
        Paint()..color = Colors.white.withAlpha(130),
      );
    }

    _drawHeart(canvas, Offset(size.width * .24, size.height * .62),
        size.width * .12, const Color(0xffff6685));
    _drawHeart(canvas, Offset(size.width * .76, size.height * .60),
        size.width * .11, const Color(0xffff6685));
  }

  void _drawLollipop(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    Color color,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = color.withAlpha(60),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * .16
      ..strokeCap = StrokeCap.round
      ..color = color;
    final path = Path();
    for (var i = 0; i < 38; i++) {
      final t = i / 37 * math.pi * 5.8;
      final r = radius * (.08 + .78 * i / 37);
      final point = center + Offset(math.cos(t) * r, math.sin(t) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, paint);
    canvas.drawCircle(
        center, radius, Paint()..color = Colors.white.withAlpha(26));
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy + size * .35)
      ..cubicTo(
          center.dx - size,
          center.dy - size * .25,
          center.dx - size * .45,
          center.dy - size,
          center.dx,
          center.dy - size * .35)
      ..cubicTo(center.dx + size * .45, center.dy - size, center.dx + size,
          center.dy - size * .25, center.dx, center.dy + size * .35);
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
      center.translate(-size * .16, -size * .30),
      size * .13,
      Paint()..color = Colors.white.withAlpha(110),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.sizeOf(context).width * .82,
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(44),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xfff78abb), _primaryHot],
          ),
          boxShadow: const [
            BoxShadow(color: _primaryDark, offset: Offset(0, 12)),
            BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 16)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 62),
            SizedBox(width: 18),
            Text(
              'PLAY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w500,
                letterSpacing: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutMenu extends StatelessWidget {
  const _ShortcutMenu({
    required this.onDaily,
    required this.onShop,
    required this.onSettings,
  });

  final VoidCallback onDaily;
  final VoidCallback onShop;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ShortcutItem(
            label: 'DAILY',
            icon: Icons.redeem_rounded,
            color: _secondary,
            onTap: onDaily,
          ),
          _ShortcutItem(
            label: 'SHOP',
            icon: Icons.shopping_bag_rounded,
            color: _tertiary,
            onTap: onShop,
          ),
          _ShortcutItem(
            label: 'SETTINGS',
            icon: Icons.settings_rounded,
            color: const Color(0xff8b7f86),
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: SizedBox(
        width: 86,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 14,
                      offset: Offset(0, 8)),
                  BoxShadow(color: Color(0x20a33467), offset: Offset(0, 5)),
                ],
              ),
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: color.withAlpha(28),
                  ),
                  child: Icon(icon, color: color, size: 31),
                ),
              ),
            ),
            const SizedBox(height: 13),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _softText,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBottomNavigation extends StatelessWidget {
  const _HomeBottomNavigation({
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
              color: Color(0x14000000), blurRadius: 22, offset: Offset(0, -8)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomNavItem(
            label: 'HOME',
            icon: Icons.home_rounded,
            active: true,
            onTap: onHome,
          ),
          _BottomNavItem(
            label: 'MAP',
            icon: Icons.map_rounded,
            active: false,
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
                    offset: Offset(0, 7)),
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
