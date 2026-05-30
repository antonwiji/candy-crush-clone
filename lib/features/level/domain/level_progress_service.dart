import '../../../core/storage/local_storage_service.dart';
import 'level_progress.dart';

class LevelProgressService {
  LevelProgressService(this._storage);

  static const String keyCurrentLevel = 'current_level';
  static const String keyUnlockedLevel = 'unlocked_level';
  static const String keyLastCompletedLevel = 'last_completed_level';

  final LocalStorageService _storage;

  int get currentLevel => _storage.getInt(keyCurrentLevel, defaultValue: 1);
  int get unlockedLevel => _storage.getInt(keyUnlockedLevel, defaultValue: 1);
  int get lastCompletedLevel =>
      _storage.getInt(keyLastCompletedLevel, defaultValue: 0);

  LevelProgress getProgress() {
    return LevelProgress(
      currentLevel: currentLevel,
      unlockedLevel: unlockedLevel,
      lastCompletedLevel: lastCompletedLevel,
    );
  }

  Future<void> selectLevel(int levelNumber) async {
    if (levelNumber <= 0 || levelNumber > unlockedLevel) {
      return;
    }
    await _storage.setInt(keyCurrentLevel, levelNumber);
  }

  Future<LevelProgress> completeLevel(int levelNumber) async {
    if (levelNumber <= 0) {
      return getProgress();
    }

    final existingUnlockedLevel = unlockedLevel;
    final existingLastCompleted = lastCompletedLevel;
    final updatedUnlockedLevel = levelNumber >= existingUnlockedLevel
        ? levelNumber + 1
        : existingUnlockedLevel;
    final updatedCurrentLevel =
        levelNumber >= existingUnlockedLevel ? levelNumber + 1 : currentLevel;
    final updatedLastCompleted = levelNumber > existingLastCompleted
        ? levelNumber
        : existingLastCompleted;

    await _storage.setInt(keyLastCompletedLevel, updatedLastCompleted);
    await _storage.setInt(keyUnlockedLevel, updatedUnlockedLevel);
    await _storage.setInt(keyCurrentLevel, updatedCurrentLevel);

    return getProgress();
  }
}
