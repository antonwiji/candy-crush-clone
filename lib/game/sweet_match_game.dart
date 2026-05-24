import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'board/board_component.dart';
import 'board/board_controller.dart';
import 'board/board_position.dart';
import 'game_config.dart';
import 'game_snapshot.dart';
import 'game_state.dart';
import 'level/level_config.dart';
import 'level/level_loader.dart';

class SweetMatchGame extends FlameGame {
  static const String mainMenuOverlay = 'MainMenu';
  static const String hudOverlay = 'HUD';
  static const String pauseOverlay = 'Pause';
  static const String levelCompleteOverlay = 'LevelComplete';
  static const String gameOverOverlay = 'GameOver';

  final ValueNotifier<GameSnapshot> stats =
      ValueNotifier<GameSnapshot>(const GameSnapshot.initial());
  final LevelLoader _levelLoader = const LevelLoader();

  GameState state = GameState.mainMenu;
  LevelConfig? _level;
  BoardController? controller;
  BoardComponent? boardComponent;

  @override
  Color backgroundColor() => const Color(0xffffd9e7);

  Future<void> startGame() async {
    state = GameState.loading;
    _level ??= await _levelLoader.load(GameConfig.firstLevelAsset);
    controller = BoardController(_level!);
    boardComponent?.removeFromParent();
    boardComponent = BoardComponent(
      controller: controller!,
      onTilePressed: _onTilePressed,
    );
    await camera.viewport.add(boardComponent!);
    overlays
      ..remove(mainMenuOverlay)
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

  Future<void> _performSwap(BoardPosition first, BoardPosition second) async {
    state = GameState.animating;
    final result = controller!.trySwap(first, second);
    _updateStats(
      message: result.isValid
          ? result.cascadeCount > 1
              ? 'Combo x${result.cascadeCount}! +${result.scoreGained}'
              : '+${result.scoreGained}'
          : 'Swap tidak menghasilkan match',
    );
    await Future<void>.delayed(const Duration(milliseconds: 230));
    if (controller!.isWon) {
      state = GameState.levelComplete;
      overlays.add(levelCompleteOverlay);
    } else if (controller!.isGameOver) {
      state = GameState.gameOver;
      overlays.add(gameOverOverlay);
    } else {
      state = GameState.playing;
    }
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
      ..remove(pauseOverlay)
      ..remove(levelCompleteOverlay)
      ..remove(gameOverOverlay)
      ..add(mainMenuOverlay);
  }

  void _updateStats({String message = ''}) {
    final game = controller!;
    stats.value = GameSnapshot(
      score: game.score,
      moves: game.movesRemaining,
      target: _level!.objective.label(score: game.score, collected: game.collected),
      levelName: _level!.name,
      message: message,
    );
  }

  @override
  void onRemove() {
    stats.dispose();
    super.onRemove();
  }
}
