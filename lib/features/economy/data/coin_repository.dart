import '../../../core/storage/local_storage_service.dart';

class CoinRepository {
  CoinRepository(this._storage);

  static const String coinKey = 'player_coin_total';

  final LocalStorageService _storage;

  int getCoin() => _storage.getInt(coinKey);

  Future<int> addCoin(int amount) async {
    final updatedCoin = getCoin() + amount;
    await _storage.setInt(coinKey, updatedCoin);
    return updatedCoin;
  }

  Future<void> setCoin(int amount) async {
    await _storage.setInt(coinKey, amount);
  }
}
