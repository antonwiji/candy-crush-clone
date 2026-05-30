enum LevelStatus { completed, current, unlocked, locked }

class LevelMapItem {
  const LevelMapItem({
    required this.level,
    required this.status,
    this.stars = 0,
    this.targetScore = 0,
  }) : assert(stars >= 0 && stars <= 3);

  final int level;
  final LevelStatus status;
  final int stars;
  final int targetScore;

  bool get isPlayable =>
      status == LevelStatus.completed ||
      status == LevelStatus.current ||
      status == LevelStatus.unlocked;

  bool get isLocked => status == LevelStatus.locked;
}
