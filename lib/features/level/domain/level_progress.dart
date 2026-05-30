class LevelProgress {
  const LevelProgress({
    required this.currentLevel,
    required this.unlockedLevel,
    required this.lastCompletedLevel,
  });

  final int currentLevel;
  final int unlockedLevel;
  final int lastCompletedLevel;
}
