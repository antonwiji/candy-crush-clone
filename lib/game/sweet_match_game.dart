import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/audio/audio_manager.dart';
import '../core/storage/local_storage_service.dart';
import '../features/economy/data/coin_repository.dart';
import '../features/economy/domain/coin_service.dart';
import '../features/economy/domain/game_reward_config.dart';
import '../features/level/domain/level_progress.dart';
import '../features/level/domain/level_progress_service.dart';
import 'board/board_component.dart';
import 'board/board_controller.dart';
import 'board/board_position.dart';
import 'game_snapshot.dart';
import 'game_state.dart';
import 'level/generated_level_config.dart';
import 'level/level_config.dart';
import 'level/level_generator.dart';
import 'level/level_templates.dart';
import 'level/level_objective.dart';

class SweetMatchGame extends FlameGame {
  static const String mainMenuOverlay = 'MainMenu';
  static const String levelMapOverlay = 'LevelMap';
  static const String hudOverlay = 'HUD';
  static const String pauseOverlay = 'Pause';
  static const String levelCompleteOverlay = 'LevelComplete';
  static const String gameOverOverlay = 'GameOver';

  final ValueNotifier<GameSnapshot> stats =
      ValueNotifier<GameSnapshot>(const GameSnapshot.initial());
  final LevelGenerator _levelGenerator =
      const LevelGenerator(templates: levelTemplates);

  GameState state = GameState.mainMenu;
  LevelConfig? _level;
  GeneratedLevelConfig? _generatedLevel;
  BoardController? controller;
  BoardComponent? boardComponent;
  CoinService? _coinService;
  LevelProgressService? _levelProgressService;
  int _coinTotal = 0;
  int _coinRewardSequence = 0;
  bool _isWinningTriggered = false;

  @override
  Color backgroundColor() => const Color(0xfffffcfd);

  Future<int> loadCoinTotal() async {
    await _loadCoinService();
    return _coinTotal;
  }

  Future<LevelProgress> loadLevelProgress() async {
    await _loadLevelProgressService();
    return _levelProgressService!.getProgress();
  }

  Future<void> startGame() async {
    await _loadLevelProgressService();
    await startLevel(_levelProgressService!.currentLevel);
  }

  Future<void> startLevel(int levelNumber) async {
    if (state == GameState.loading) {
      return;
    }
    state = GameState.loading;
    await _loadCoinService();
    await _loadLevelProgressService();
    _coinService!.resetLevelSession();
    _isWinningTriggered = false;
    _generatedLevel = _levelGenerator.generate(levelNumber);
    _level = LevelConfig.fromGenerated(_generatedLevel!);
    controller = BoardController(_level!);
    boardComponent?.removeFromParent();
    boardComponent = BoardComponent(
      controller: controller!,
      onTilePressed: _onTilePressed,
      onSwipe: _onSwipe,
      onBoardChanged: _updateStats,
      onMatchScored: _onMatchScored,
    );
    await camera.viewport.add(boardComponent!);
    overlays
      ..remove(mainMenuOverlay)
      ..remove(levelMapOverlay)
      ..remove(pauseOverlay)
      ..remove(levelCompleteOverlay)
      ..remove(gameOverOverlay)
      ..add(hudOverlay);
    state = GameState.playing;
    _updateStats();
  }

  void _onTilePressed(BoardPosition position) {
    if (state != GameState.playing) {
      return;
    }
    final component = boardComponent!;
    final current = component.selected;
    if (current == null) {
      component.selected = position;
      return;
    }
    if (current == position) {
      component.selected = null;
      return;
    }
    if (!current.isAdjacentTo(position)) {
      component.selected = position;
      return;
    }
    component.selected = null;
    unawaited(_performSwap(current, position));
  }

  void _onSwipe(BoardPosition first, BoardPosition second) {
    if (state != GameState.playing) {
      return;
    }
    boardComponent!.selected = null;
    unawaited(_performSwap(first, second));
  }

  Future<void> _performSwap(BoardPosition first, BoardPosition second) async {
    state = GameState.animating;
    unawaited(AudioManager.playSlideSfx());
    final result = await boardComponent!.animateSwap(first, second);
    _updateStats(
      message: result.isValid
          ? result.cascadeCount > 1
              ? 'Combo x${result.cascadeCount}! +${result.scoreGained}'
              : '+${result.scoreGained}'
          : 'Swap tidak menghasilkan match',
    );
    if (controller!.isWon && !_isWinningTriggered) {
      _isWinningTriggered = true;
      state = GameState.levelComplete;
      final rewarded = await _rewardLevelCompleted();
      if (rewarded) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
      }
      overlays.add(levelCompleteOverlay);
    } else if (controller!.isGameOver) {
      state = GameState.gameOver;
      overlays.add(gameOverOverlay);
    } else {
      state = GameState.playing;
    }
  }

  void _onMatchScored(int cascade) {
    unawaited(AudioManager.playComboHitSfx(cascade));
  }

  void pauseGame() {
    if (state != GameState.playing) {
      return;
    }
    state = GameState.paused;
    pauseEngine();
    overlays.add(pauseOverlay);
  }

  void resumeGame() {
    if (state != GameState.paused) {
      return;
    }
    overlays.remove(pauseOverlay);
    resumeEngine();
    state = GameState.playing;
  }

  Future<void> restartGame() async {
    resumeEngine();
    await startGame();
  }

  void returnToMenu() {
    resumeEngine();
    state = GameState.mainMenu;
    boardComponent?.removeFromParent();
    boardComponent = null;
    overlays
      ..remove(hudOverlay)
      ..remove(levelMapOverlay)
      ..remove(pauseOverlay)
      ..remove(levelCompleteOverlay)
      ..remove(gameOverOverlay)
      ..add(mainMenuOverlay);
  }

  void showLevelMap() {
    resumeEngine();
    state = GameState.mainMenu;
    boardComponent?.removeFromParent();
    boardComponent = null;
    overlays
      ..remove(mainMenuOverlay)
      ..remove(hudOverlay)
      ..remove(pauseOverlay)
      ..remove(levelCompleteOverlay)
      ..remove(gameOverOverlay)
      ..add(levelMapOverlay);
  }

  void _updateStats({String message = ''}) {
    final game = controller!;
    final objective = _level!.objective;
    stats.value = GameSnapshot(
      score: game.score,
      moves: game.movesRemaining,
      target: objective.label(score: game.score, collected: game.collected),
      targetScore: objective is ScoreObjective ? objective.targetScore : 0,
      levelNumber: _level!.id,
      levelName: _level!.name,
      coinTotal: _coinTotal,
      coinRewardSequence: _coinRewardSequence,
      message: message,
    );
  }

  Future<void> _loadCoinService() async {
    _coinService ??= CoinService(
      CoinRepository(await LocalStorageService.create()),
    );
    _coinTotal = _coinService!.currentCoin;
  }

  Future<void> _loadLevelProgressService() async {
    _levelProgressService ??= LevelProgressService(
      await LocalStorageService.create(),
    );
  }

  Future<bool> _rewardLevelCompleted() async {
    await _levelProgressService!.completeLevel(_level!.id);
    final updatedCoin = await _coinService!.rewardLevelCompleted(
      amount: _generatedLevel?.rewardCoin ?? GameRewardConfig.winCoinReward,
    );
    if (updatedCoin == null) {
      return false;
    }
    _coinTotal = updatedCoin;
    _coinRewardSequence++;
    _updateStats(message: '+${GameRewardConfig.winCoinReward} COINS!');
    return true;
  }

  @override
  void onRemove() {
    stats.dispose();
    super.onRemove();
  }
}
