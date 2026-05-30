import 'dart:async';

import 'package:flutter/material.dart';

import '../core/audio/audio_manager.dart';
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
                    top: 70,
                    right: 22,
                    child: _ObjectiveRow(snapshot: snapshot),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    top: 160,
                    child: _CurrentScoreCard(snapshot: snapshot),
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

  void _handlePausePressed() {
    unawaited(AudioManager.playClickMenuSfx());
    onPause();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LevelBadge(levelNumber: levelNumber),
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
            onPressed: _handlePausePressed,
            icon: const Icon(Icons.pause_rounded,
                color: Color(0xff654d55), size: 25),
          ),
        ),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.levelNumber});

  final int levelNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xfffff2f8), Colors.white],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xfff1d0df)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14a33467),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'LEVEL',
            style: TextStyle(
              color: Color(0xffa89198),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.25,
            ),
          ),
          Text(
            '$levelNumber',
            style: const TextStyle(
              color: _primary,
              height: .95,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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

class _ObjectiveRow extends StatelessWidget {
  const _ObjectiveRow({required this.snapshot});

  final GameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _TargetScoreCard(targetScore: snapshot.targetScore),
        ),
        const SizedBox(width: 12),
        _MovesBadge(moves: snapshot.moves),
      ],
    );
  }
}

class _TargetScoreCard extends StatelessWidget {
  const _TargetScoreCard({required this.targetScore});

  final int targetScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xfffff4f9), Colors.white],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xfff1d5e2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16a33467),
            blurRadius: 15,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xffff8fbc), _primary],
              ),
            ),
            child:
                const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TARGET SCORE',
                style: TextStyle(
                  color: _outline,
                  fontSize: 9,
                  letterSpacing: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_format(targetScore)} pts',
                style: const TextStyle(
                  color: _primary,
                  fontSize: 22,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MovesBadge extends StatelessWidget {
  const _MovesBadge({required this.moves});

  final int moves;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
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
              color: Color(0x377644b5), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'MOVES',
            style: TextStyle(
                color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
          ),
          Text(
            '$moves',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w500,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentScoreCard extends StatefulWidget {
  const _CurrentScoreCard({required this.snapshot});

  final GameSnapshot snapshot;

  @override
  State<_CurrentScoreCard> createState() => _CurrentScoreCardState();
}

class _CurrentScoreCardState extends State<_CurrentScoreCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 430),
  );
  late int _scoreFrom = widget.snapshot.score;
  int _gain = 0;
  bool _showGain = false;

  @override
  void didUpdateWidget(covariant _CurrentScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.snapshot.score > oldWidget.snapshot.score) {
      _scoreFrom = oldWidget.snapshot.score;
      _gain = widget.snapshot.score - oldWidget.snapshot.score;
      _showGain = true;
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.snapshot.progress;
    final emphasized = progress >= .8;
    final success = progress >= 1;
    final accent = success
        ? const Color(0xff40af7a)
        : emphasized
            ? const Color(0xffed4f91)
            : _primary;
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, _) {
        final effectProgress =
            Curves.easeOut.transform(_bounceController.value);
        final scale = TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1, end: 1.025), weight: 36),
          TweenSequenceItem(tween: Tween(begin: 1.025, end: 1), weight: 64),
        ]).transform(_bounceController.value);
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.fromLTRB(13, 9, 13, 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xfffff3f8)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xfff1d5e2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x15a33467),
                  blurRadius: 15,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                color: _primary, size: 15),
                            SizedBox(width: 5),
                            Text(
                              'CURRENT SCORE',
                              style: TextStyle(
                                color: _outline,
                                fontSize: 9,
                                letterSpacing: 1.35,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: List.generate(3, (index) {
                            final active = progress >= (index + 1) / 3;
                            return Icon(
                              Icons.star_rounded,
                              size: 17,
                              color: active
                                  ? const Color(0xffe59b13)
                                  : const Color(0xffdee0e4),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(
                        begin: _scoreFrom,
                        end: widget.snapshot.score,
                      ),
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      onEnd: () => _scoreFrom = widget.snapshot.score,
                      builder: (context, value, _) => Text(
                        '${_format(value)} pts',
                        style: TextStyle(
                          color: accent,
                          fontSize: 26,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: progress),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                            backgroundColor: const Color(0xfff0f0f3),
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          );
                        },
                      ),
                    ),
                    if (widget.snapshot.message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.snapshot.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_showGain && _bounceController.value < 1)
                  Positioned(
                    right: 66,
                    top: 28 - effectProgress * 15,
                    child: Opacity(
                      opacity: 1 - effectProgress,
                      child: Text(
                        '+$_gain',
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
