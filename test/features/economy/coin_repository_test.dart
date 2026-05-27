import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet_match_game/core/storage/local_storage_service.dart';
import 'package:sweet_match_game/features/economy/data/coin_repository.dart';

void main() {
  group('CoinRepository', () {
    test('returns zero when a coin value does not exist', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = CoinRepository(await LocalStorageService.create());

      expect(repository.getCoin(), 0);
    });

    test('adds and persists the updated coin value', () async {
      SharedPreferences.setMockInitialValues({CoinRepository.coinKey: 20});
      final repository = CoinRepository(await LocalStorageService.create());

      final updatedCoin = await repository.addCoin(5);

      expect(updatedCoin, 25);
      expect(repository.getCoin(), 25);
      final reloaded = CoinRepository(await LocalStorageService.create());
      expect(reloaded.getCoin(), 25);
    });
  });
}
