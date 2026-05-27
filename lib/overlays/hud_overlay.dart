import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../game/game_snapshot.dart';
import '../game/sweet_match_game.dart';

const _primary = Color(0xffa33467);
const _secondary = Color(0xff7644b5);
const _tertiary = Color(0xffa06100);
const _outline = Color(0xff887178);

class HudOverlay extends StatelessWidget {
  const HudOverlay({required this.game, super.key});

  final SweetMatchGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<GameSnapshot>(
        valueListenable: game.stats,
        builder: (context, snapshot, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final boardSize =
                  constraints.maxWidth - GameConfig.boardPadding * 2;
              final boosterTop = GameConfig.boardTop -
                  MediaQuery.paddingOf(context).top +
                  boardSize +
                  14;
              return Stack(
                children: [
                  Positioned(
                    left: 18,
                    top: 8,
                    right: 18,
                    child: _TopBar(
                      levelNumber: snapshot.levelNumber,
                      coinTotal: snapshot.coinTotal,
                      coinRewardSequence: snapshot.coinRewardSequence,
                      onPause: game.pauseGame,
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 78,
                    right: 22,
                    child: _ScoreArea(snapshot: snapshot),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    top: 210,
                    child: _ProgressSection(snapshot: snapshot),
                  ),
                  Positioned(
                    left: 40,
                    right: 40,
                    top: boosterTop,
                    child: const _Boosters(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.levelNumber,
    required this.coinTotal,
    required this.coinRewardSequence,
    required this.onPause,
  });

  final int levelNumber;
  final int coinTotal;
  final int coinRewardSequence;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xffff8ebc), _primary],
            ),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x32a33467),
                  blurRadius: 12,
                  offset: Offset(0, 5)),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 23),
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LEVEL',
              style: TextStyle(
                color: Color(0xffa89198),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            Text(
              '$levelNumber',
              style: const TextStyle(
                color: _primary,
                height: 1,
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        const Text(
          'Sweet Match',
          style: TextStyle(
            color: _primary,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        _CoinBadge(
          coinTotal: coinTotal,
          rewardSequence: coinRewardSequence,
        ),
        const SizedBox(width: 7),
        Container(
          width: 43,
          height: 43,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 12,
                  offset: Offset(0, 5)),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPause,
            icon: const Icon(Icons.pause_rounded,
                color: Color(0xff654d55), size: 25),
          ),
        ),
      ],
    );
  }
}

class _CoinBadge extends StatefulWidget {
  const _CoinBadge({
    required this.coinTotal,
    required this.rewardSequence,
  });

  final int coinTotal;
  final int rewardSequence;

  @override
  State<_CoinBadge> createState() => _CoinBadgeState();
}

class _CoinBadgeState extends State<_CoinBadge>
    with SingleTickerProviderStateMixin {
  bool _showReward = false;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 680),
  );

  @override
  void didUpdateWidget(covariant _CoinBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rewardSequence > oldWidget.rewardSequence) {
      _showReward = true;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeOut.transform(_controller.value);
        final scale = TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1, end: 1.14), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.14, end: 1), weight: 70),
        ]).transform(_controller.value);
        return SizedBox(
          width: 90,
          height: 46,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.fromLTRB(9, 0, 11, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x13000000),
                          blurRadius: 12,
                          offset: Offset(0, 5)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          color: Color(0xffe6a51d), size: 20),
                      const SizedBox(width: 3),
                      Text(
                        _format(widget.coinTotal),
                        style: const TextStyle(
                          color: Color(0xff3d3235),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showReward && _controller.value < 1)
                Positioned(
                  top: -8 - 20 * progress,
                  child: Opacity(
                    opacity: 1 - progress,
                    child: Transform.scale(
                      scale: 1 + .18 * progress,
                      child: const Text(
                        '+5',
                        style: TextStyle(
                          color: Color(0xffe6a51d),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreArea extends StatelessWidget {
  const _ScoreArea({required this.snapshot});

  final GameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TARGET SCORE',
          style: TextStyle(
            color: _outline,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 166,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(27),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x17000000),
                      blurRadius: 16,
                      offset: Offset(0, 8)),
                  BoxShadow(color: Color(0xffe8e9eb), offset: Offset(0, 4)),
                ],
              ),
              child: Text(
                _format(snapshot.targetScore),
                style: const TextStyle(
                  color: _primary,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.7,
                ),
              ),
            ),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffb77bff), _secondary],
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x377644b5),
                      blurRadius: 18,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'MOVES',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${snapshot.moves}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w500,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.snapshot});

  final GameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CURRENT: ${_format(snapshot.score)}',
              style: const TextStyle(
                color: _tertiary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: .45,
              ),
            ),
            Row(
              children: List.generate(3, (index) {
                final active = snapshot.progress >= (index + 1) / 3;
                return Icon(
                  Icons.star_rounded,
                  size: 22,
                  color: active
                      ? const Color(0xffe59b13)
                      : const Color(0xffdee0e4),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 26,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 12,
                  offset: Offset(0, 5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: Color(0xfff1f2f4)),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: constraints.maxWidth * snapshot.progress,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xffff86b7), _primary],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (snapshot.message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              snapshot.message,
              style: const TextStyle(
                  color: _primary, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _Boosters extends StatelessWidget {
  const _Boosters();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Booster(
            icon: Icons.handyman_rounded,
            label: 'HAMMER',
            quantity: '3',
            color: _primary),
        _Booster(
            icon: Icons.autorenew_rounded,
            label: 'SHUFFLE',
            quantity: '5',
            color: _secondary),
        _Booster(
            icon: Icons.rocket_launch_rounded,
            label: 'BOMB',
            quantity: '1',
            color: _tertiary),
      ],
    );
  }
}

class _Booster extends StatelessWidget {
  const _Booster({
    required this.icon,
    required this.label,
    required this.quantity,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String quantity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: Colors.white),
                boxShadow: const [
                  BoxShadow(color: Color(0x22a33467), offset: Offset(0, 8)),
                  BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 16,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Icon(icon, color: color, size: 29),
            ),
            Positioned(
              right: -7,
              top: -8,
              child: Container(
                width: 25,
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffc71825),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Text(
                  quantity,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff59444b),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

String _format(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}
