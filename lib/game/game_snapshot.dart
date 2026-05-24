class GameSnapshot {
  const GameSnapshot({
    required this.score,
    required this.moves,
    required this.target,
    required this.levelName,
    this.message = '',
  });

  const GameSnapshot.initial()
      : score = 0,
        moves = 0,
        target = 'Score challenge',
        levelName = 'Sugar Sunrise',
        message = '';

  final int score;
  final int moves;
  final String target;
  final String levelName;
  final String message;
}
