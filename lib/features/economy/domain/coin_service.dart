import '../data/coin_repository.dart';
import 'game_reward_config.dart';

class CoinService {
  CoinService(this._repository);

  final CoinRepository _repository;
  bool _hasRewardClaimed = false;

  int get currentCoin => _repository.getCoin();

  Future<int?> rewardLevelCompleted() async {
    if (_hasRewardClaimed) {
      return null;
    }
    _hasRewardClaimed = true;
    return _repository.addCoin(GameRewardConfig.winCoinReward);
  }

  void resetLevelSession() {
    _hasRewardClaimed = false;
  }
}
