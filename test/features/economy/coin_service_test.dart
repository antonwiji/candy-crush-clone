import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet_match_game/core/storage/local_storage_service.dart';
import 'package:sweet_match_game/features/economy/data/coin_repository.dart';
import 'package:sweet_match_game/features/economy/domain/coin_service.dart';

void main() {
  group('CoinService', () {
    test('rewards five coins for a completed level', () async {
      SharedPreferences.setMockInitialValues({});
      final service = CoinService(
        CoinRepository(await LocalStorageService.create()),
      );

      expect(await service.rewardLevelCompleted(), 5);
      expect(service.currentCoin, 5);
    });

    test('only rewards once until a new level session starts', () async {
      SharedPreferences.setMockInitialValues({});
      final service = CoinService(
        CoinRepository(await LocalStorageService.create()),
      );

      expect(await service.rewardLevelCompleted(), 5);
      expect(await service.rewardLevelCompleted(), isNull);
      expect(service.currentCoin, 5);

      service.resetLevelSession();

      expect(await service.rewardLevelCompleted(), 10);
    });
  });
}
