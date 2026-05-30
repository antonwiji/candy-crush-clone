import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet_match_game/core/storage/local_storage_service.dart';
import 'package:sweet_match_game/features/level/domain/level_progress_service.dart';

void main() {
  group('LevelProgressService', () {
    test('defaults to the first playable level', () async {
      SharedPreferences.setMockInitialValues({});
      final service = LevelProgressService(await LocalStorageService.create());

      final progress = service.getProgress();

      expect(progress.currentLevel, 1);
      expect(progress.unlockedLevel, 1);
      expect(progress.lastCompletedLevel, 0);
    });

    test('completing the latest unlocked level opens the next level', () async {
      SharedPreferences.setMockInitialValues({});
      final service = LevelProgressService(await LocalStorageService.create());

      final progress = await service.completeLevel(5);

      expect(progress.unlockedLevel, 6);
      expect(progress.currentLevel, 6);
      expect(progress.lastCompletedLevel, 5);
    });

    test('replaying an older level does not lower unlocked progress', () async {
      SharedPreferences.setMockInitialValues({
        LevelProgressService.keyCurrentLevel: 10,
        LevelProgressService.keyUnlockedLevel: 10,
        LevelProgressService.keyLastCompletedLevel: 9,
      });
      final service = LevelProgressService(await LocalStorageService.create());

      final progress = await service.completeLevel(3);

      expect(progress.unlockedLevel, 10);
      expect(progress.currentLevel, 10);
      expect(progress.lastCompletedLevel, 9);
    });
  });
}
