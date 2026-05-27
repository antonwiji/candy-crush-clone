import 'dart:math';

import '../level/level_config.dart';
import '../tile/tile_model.dart';
import '../tile/tile_type.dart';
import 'board_interaction_state.dart';
import 'board_model.dart';
import 'board_position.dart';
import 'match_result.dart';
import 'swap_result.dart';

class BoardController {
  BoardController(this.level, {Random? random}) : _random = random ?? Random() {
    reset();
  }

  BoardController.withBoard(this.level, this.board, {Random? random})
      : _random = random ?? Random(),
        movesRemaining = level.moves;

  final LevelConfig level;
  final Random _random;
  late BoardModel board;

  int score = 0;
  late int movesRemaining;
  final Map<TileType, int> collected = {};
  BoardInteractionState interactionState = BoardInteractionState.idle;
  int _nextId = 0;

  bool get isWon =>
      level.objective.isComplete(score: score, collected: collected);
  bool get isGameOver => movesRemaining <= 0 && !isWon;
  bool get canAcceptInput => interactionState == BoardInteractionState.idle;

  void reset() {
    score = 0;
    movesRemaining = level.moves;
    collected.clear();
    interactionState = BoardInteractionState.idle;
    board = _generatePlayableBoard();
  }

  bool beginSwap(BoardPosition first, BoardPosition second) {
    if (!canAcceptInput ||
        !_isInside(first) ||
        !_isInside(second) ||
        !first.isAdjacentTo(second) ||
        movesRemaining <= 0 ||
        isWon) {
      return false;
    }

    interactionState = BoardInteractionState.swapping;
    _swap(first, second);
    return true;
  }

  void commitValidSwap() {
    movesRemaining--;
  }

  void revertSwap(BoardPosition first, BoardPosition second) {
    interactionState = BoardInteractionState.revertingSwap;
    _swap(first, second);
  }

  List<TileModel> uniqueMatchedTiles(List<MatchResult> matches) {
    return <String, TileModel>{
      for (final match in matches)
        for (final tile in match.tiles) tile.id: tile,
    }.values.toList();
  }

  int clearMatches(List<MatchResult> matches, int cascade) {
    final matchedTiles = uniqueMatchedTiles(matches);
    final gainedScore = matchedTiles.length * 10 * cascade;
    score += gainedScore;
    for (final tile in matchedTiles) {
      collected.update(tile.type, (value) => value + 1, ifAbsent: () => 1);
      board.put(tile.row, tile.col, null);
    }
    return gainedScore;
  }

  bool ensurePlayableBoard() {
    if (!isWon && movesRemaining > 0 && !hasPossibleMove()) {
      board = _generatePlayableBoard();
      return true;
    }
    return false;
  }

  void setInteractionState(BoardInteractionState state) {
    interactionState = state;
  }

  void finishInteraction() {
    interactionState = BoardInteractionState.idle;
  }

  SwapResult trySwap(BoardPosition first, BoardPosition second) {
    if (!beginSwap(first, second)) {
      return const SwapResult.invalid();
    }

    var matches = findMatches();
    if (matches.isEmpty) {
      revertSwap(first, second);
      finishInteraction();
      return const SwapResult.invalid();
    }

    commitValidSwap();
    final scoreBefore = score;
    var cascade = 0;
    var clearedCount = 0;
    while (matches.isNotEmpty) {
      cascade++;
      final matchedTiles = uniqueMatchedTiles(matches);
      clearedCount += matchedTiles.length;
      clearMatches(matches, cascade);
      applyGravity();
      refill();
      matches = findMatches();
    }

    ensurePlayableBoard();
    finishInteraction();

    return SwapResult(
      isValid: true,
      scoreGained: score - scoreBefore,
      cascadeCount: cascade,
      clearedTiles: clearedCount,
    );
  }

  List<MatchResult> findMatches() {
    final results = <MatchResult>[];
    for (var row = 0; row < board.rows; row++) {
      var start = 0;
      while (start < board.cols) {
        final tile = board.tileAt(row, start);
        var end = start + 1;
        while (tile != null &&
            end < board.cols &&
            board.tileAt(row, end)?.type == tile.type) {
          end++;
        }
        if (tile != null && end - start >= 3) {
          results.add(
            MatchResult(
              tiles: [
                for (var col = start; col < end; col++) board.tileAt(row, col)!,
              ],
              isHorizontal: true,
              isVertical: false,
            ),
          );
        }
        start = end;
      }
    }

    for (var col = 0; col < board.cols; col++) {
      var start = 0;
      while (start < board.rows) {
        final tile = board.tileAt(start, col);
        var end = start + 1;
        while (tile != null &&
            end < board.rows &&
            board.tileAt(end, col)?.type == tile.type) {
          end++;
        }
        if (tile != null && end - start >= 3) {
          results.add(
            MatchResult(
              tiles: [
                for (var row = start; row < end; row++) board.tileAt(row, col)!,
              ],
              isHorizontal: false,
              isVertical: true,
            ),
          );
        }
        start = end;
      }
    }
    return results;
  }

  void applyGravity() {
    for (var col = 0; col < board.cols; col++) {
      var targetRow = board.rows - 1;
      for (var row = board.rows - 1; row >= 0; row--) {
        final tile = board.tileAt(row, col);
        if (tile != null) {
          if (targetRow != row) {
            board.put(targetRow, col, tile);
            board.put(row, col, null);
          }
          targetRow--;
        }
      }
      while (targetRow >= 0) {
        board.put(targetRow--, col, null);
      }
    }
  }

  void refill() {
    for (var row = 0; row < board.rows; row++) {
      for (var col = 0; col < board.cols; col++) {
        if (board.tileAt(row, col) == null) {
          board.put(row, col, _newTile(row, col));
        }
      }
    }
  }

  bool hasPossibleMove() {
    for (var row = 0; row < board.rows; row++) {
      for (var col = 0; col < board.cols; col++) {
        final first = BoardPosition(row: row, col: col);
        for (final second in [
          BoardPosition(row: row, col: col + 1),
          BoardPosition(row: row + 1, col: col),
        ]) {
          if (!_isInside(second)) {
            continue;
          }
          _swap(first, second);
          final works = findMatches().isNotEmpty;
          _swap(first, second);
          if (works) {
            return true;
          }
        }
      }
    }
    return false;
  }

  BoardModel _generatePlayableBoard() {
    for (var attempt = 0; attempt < 250; attempt++) {
      final candidate = BoardModel.empty(rows: level.rows, cols: level.cols);
      board = candidate;
      for (var row = 0; row < level.rows; row++) {
        for (var col = 0; col < level.cols; col++) {
          TileModel tile;
          do {
            tile = _newTile(row, col);
          } while (_wouldCreateStartingMatch(tile, row, col));
          candidate.put(row, col, tile);
        }
      }
      if (hasPossibleMove()) {
        return candidate;
      }
    }
    throw StateError('Could not generate a board with a valid move.');
  }

  bool _wouldCreateStartingMatch(TileModel tile, int row, int col) {
    final horizontal = col >= 2 &&
        board.tileAt(row, col - 1)?.type == tile.type &&
        board.tileAt(row, col - 2)?.type == tile.type;
    final vertical = row >= 2 &&
        board.tileAt(row - 1, col)?.type == tile.type &&
        board.tileAt(row - 2, col)?.type == tile.type;
    return horizontal || vertical;
  }

  TileModel _newTile(int row, int col) {
    return TileModel(
      id: 'tile_${_nextId++}',
      type: level.tileTypes[_random.nextInt(level.tileTypes.length)],
      row: row,
      col: col,
    );
  }

  bool _isInside(BoardPosition position) {
    return position.row >= 0 &&
        position.row < board.rows &&
        position.col >= 0 &&
        position.col < board.cols;
  }

  void _swap(BoardPosition first, BoardPosition second) {
    final firstTile = board.tileAt(first.row, first.col);
    final secondTile = board.tileAt(second.row, second.col);
    board.put(first.row, first.col, secondTile);
    board.put(second.row, second.col, firstTile);
  }
}
