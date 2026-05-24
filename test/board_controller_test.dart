import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sweet_match_game/game/board/board_controller.dart';
import 'package:sweet_match_game/game/board/board_model.dart';
import 'package:sweet_match_game/game/board/board_position.dart';
import 'package:sweet_match_game/game/level/level_config.dart';
import 'package:sweet_match_game/game/level/level_objective.dart';
import 'package:sweet_match_game/game/tile/tile_type.dart';

void main() {
  const standardLevel = LevelConfig(
    id: 1,
    name: 'Test Level',
    rows: 8,
    cols: 8,
    moves: 20,
    tileTypes: TileType.values,
    objective: ScoreObjective(targetScore: 1000),
  );

  group('board generation', () {
    test('starts without automatic matches and with at least one move', () {
      final controller = BoardController(standardLevel, random: Random(4));

      expect(controller.findMatches(), isEmpty);
      expect(controller.hasPossibleMove(), isTrue);
    });
  });

  group('match detection', () {
    test('detects horizontal and vertical runs', () {
      final controller = _controllerFor([
        [TileType.red, TileType.red, TileType.red, TileType.blue],
        [TileType.green, TileType.yellow, TileType.blue, TileType.purple],
        [TileType.orange, TileType.yellow, TileType.green, TileType.purple],
        [TileType.blue, TileType.yellow, TileType.orange, TileType.purple],
      ]);

      final matches = controller.findMatches();

      expect(matches.any((match) => match.isHorizontal), isTrue);
      expect(matches.any((match) => match.isVertical), isTrue);
    });
  });

  group('swaps', () {
    test('a valid adjacent swap clears tiles, scores, and uses one move', () {
      final controller = _controllerFor([
        [TileType.red, TileType.green, TileType.red, TileType.blue],
        [TileType.blue, TileType.red, TileType.green, TileType.yellow],
        [TileType.green, TileType.blue, TileType.yellow, TileType.orange],
        [TileType.orange, TileType.purple, TileType.blue, TileType.green],
      ]);

      final result = controller.trySwap(
        const BoardPosition(row: 0, col: 1),
        const BoardPosition(row: 1, col: 1),
      );

      expect(result.isValid, isTrue);
      expect(result.clearedTiles, greaterThanOrEqualTo(3));
      expect(controller.score, greaterThanOrEqualTo(30));
      expect(controller.movesRemaining, 19);
    });

    test('an invalid or non-adjacent swap does not use a move', () {
      final controller = _controllerFor([
        [TileType.red, TileType.blue, TileType.green, TileType.yellow],
        [TileType.blue, TileType.green, TileType.yellow, TileType.purple],
        [TileType.green, TileType.yellow, TileType.purple, TileType.orange],
        [TileType.yellow, TileType.purple, TileType.orange, TileType.red],
      ]);

      expect(
        controller
            .trySwap(
              const BoardPosition(row: 0, col: 0),
              const BoardPosition(row: 0, col: 1),
            )
            .isValid,
        isFalse,
      );
      expect(
        controller
            .trySwap(
              const BoardPosition(row: 0, col: 0),
              const BoardPosition(row: 2, col: 0),
            )
            .isValid,
        isFalse,
      );
      expect(controller.movesRemaining, 20);
    });
  });

  test('gravity pulls surviving tiles into empty positions', () {
    final controller = _controllerFor([
      [TileType.red, TileType.blue, TileType.green, TileType.yellow],
      [TileType.blue, TileType.green, TileType.yellow, TileType.purple],
      [TileType.green, TileType.yellow, TileType.purple, TileType.orange],
      [TileType.yellow, TileType.purple, TileType.orange, TileType.red],
    ]);
    final topType = controller.board.tileAt(0, 0)!.type;
    controller.board.put(3, 0, null);

    controller.applyGravity();

    expect(controller.board.tileAt(1, 0)!.type, topType);
    expect(controller.board.tileAt(0, 0), isNull);
  });

  test('refill populates every empty position', () {
    final controller = _controllerFor([
      [TileType.red, TileType.blue, TileType.green, TileType.yellow],
      [TileType.blue, TileType.green, TileType.yellow, TileType.purple],
      [TileType.green, TileType.yellow, TileType.purple, TileType.orange],
      [TileType.yellow, TileType.purple, TileType.orange, TileType.red],
    ]);
    controller.board
      ..put(0, 0, null)
      ..put(1, 2, null);

    controller.refill();

    expect(controller.board.tiles.length, 16);
  });

  test('score objective reports completion', () {
    final completed = _controllerFor([
      [TileType.red, TileType.blue, TileType.green, TileType.yellow],
      [TileType.blue, TileType.green, TileType.yellow, TileType.purple],
      [TileType.green, TileType.yellow, TileType.purple, TileType.orange],
      [TileType.yellow, TileType.purple, TileType.orange, TileType.red],
    ]);
    completed.score = 1000;
    expect(completed.isWon, isTrue);
  });

  test('using the final valid move without reaching the target is game over', () {
    final controller = _controllerFor(
      [
        [TileType.red, TileType.green, TileType.red, TileType.blue],
        [TileType.blue, TileType.red, TileType.green, TileType.yellow],
        [TileType.green, TileType.blue, TileType.yellow, TileType.orange],
        [TileType.orange, TileType.purple, TileType.blue, TileType.green],
      ],
      moves: 1,
      targetScore: 10000,
    );

    controller.trySwap(
      const BoardPosition(row: 0, col: 1),
      const BoardPosition(row: 1, col: 1),
    );

    expect(controller.movesRemaining, 0);
    expect(controller.isGameOver, isTrue);
  });
}

BoardController _controllerFor(
  List<List<TileType>> values, {
  int moves = 20,
  int targetScore = 1000,
}) {
  final level = LevelConfig(
    id: 1,
    name: 'Fixture',
    rows: values.length,
    cols: values.first.length,
    moves: moves,
    tileTypes: TileType.values,
    objective: ScoreObjective(targetScore: targetScore),
  );
  return BoardController.withBoard(
    level,
    BoardModel.fromTypes(values),
    random: Random(8),
  );
}
