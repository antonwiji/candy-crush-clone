class GameSnapshot {
  const GameSnapshot({
    required this.score,
    required this.moves,
    required this.target,
    required this.targetScore,
    required this.levelNumber,
    required this.levelName,
    required this.coinTotal,
    required this.coinRewardSequence,
    this.message = '',
  });

  const GameSnapshot.initial()
      : score = 0,
        moves = 0,
        target = 'Score challenge',
        targetScore = 0,
        levelNumber = 1,
        levelName = 'Sugar Sunrise',
        coinTotal = 0,
        coinRewardSequence = 0,
        message = '';

  final int score;
  final int moves;
  final String target;
  final int targetScore;
  final int levelNumber;
  final String levelName;
  final int coinTotal;
  final int coinRewardSequence;
  final String message;

  double get progress {
    if (targetScore <= 0) {
      return 0;
    }
    return (score / targetScore).clamp(0, 1);
  }
}
