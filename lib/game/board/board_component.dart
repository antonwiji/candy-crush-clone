import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../effects/floating_score_component.dart';
import '../effects/tile_animation_service.dart';
import '../game_config.dart';
import '../tile/tile_component.dart';
import 'board_controller.dart';
import 'board_interaction_state.dart';
import 'board_position.dart';
import 'swap_result.dart';

class BoardComponent extends PositionComponent
    with TapCallbacks, DragCallbacks {
  BoardComponent({
    required this.controller,
    required this.onTilePressed,
    required this.onSwipe,
    required this.onBoardChanged,
  });

  final BoardController controller;
  final void Function(BoardPosition position) onTilePressed;
  final void Function(BoardPosition first, BoardPosition second) onSwipe;
  final void Function() onBoardChanged;
  final TileAnimationService _animations = TileAnimationService();
  final Map<String, TileComponent> _tiles = {};
  double _tileSize = 0;
  BoardPosition? _selected;
  BoardPosition? _dragOrigin;
  Vector2 _dragDelta = Vector2.zero();
  bool _tilesBuilt = false;

  BoardPosition? get selected => _selected;

  set selected(BoardPosition? value) {
    _selected = value;
    for (final tile in _tiles.values) {
      tile.isSelected = value != null &&
          tile.tile.row == value.row &&
          tile.tile.col == value.col;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (_tileSize > 0) {
      await _buildInitialTiles();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final availableWidth = size.x - GameConfig.boardPadding * 2;
    final availableHeight =
        size.y - GameConfig.boardTop - GameConfig.boardBottomPadding;
    final boardSize = math.min(availableWidth, availableHeight);
    _tileSize =
        (boardSize - GameConfig.boardInnerPadding * 2) / controller.board.cols;
    this.size = Vector2.all(boardSize);
    position = Vector2((size.x - this.size.x) / 2, GameConfig.boardTop);
    if (!_tilesBuilt && isMounted) {
      unawaited(_buildInitialTiles());
    } else if (controller.canAcceptInput) {
      for (final tile in _tiles.values) {
        tile.position = _centerFor(tile.tile.row, tile.tile.col);
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!controller.canAcceptInput) {
      return;
    }
    final position = _positionFromLocal(event.localPosition);
    if (position != null) {
      onTilePressed(position);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragOrigin = controller.canAcceptInput
        ? _positionFromLocal(event.localPosition)
        : null;
    _dragDelta = Vector2.zero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _dragDelta += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final first = _dragOrigin;
    if (first == null ||
        !controller.canAcceptInput ||
        _dragDelta.length < _tileSize * .24) {
      return;
    }
    final horizontal = _dragDelta.x.abs() > _dragDelta.y.abs();
    final second = BoardPosition(
      row: first.row + (horizontal ? 0 : (_dragDelta.y.sign.toInt())),
      col: first.col + (horizontal ? (_dragDelta.x.sign.toInt()) : 0),
    );
    if (_isInside(second)) {
      onSwipe(first, second);
    }
  }

  Future<SwapResult> animateSwap(
    BoardPosition first,
    BoardPosition second,
  ) async {
    final firstTile = _tileAt(first);
    final secondTile = _tileAt(second);
    if (firstTile == null ||
        secondTile == null ||
        !controller.beginSwap(first, second)) {
      return const SwapResult.invalid();
    }

    selected = null;
    var interactionFinished = false;
    try {
      await _animations.swapTiles(
        firstTile,
        secondTile,
        _centerFor(firstTile.tile.row, firstTile.tile.col),
        _centerFor(secondTile.tile.row, secondTile.tile.col),
      );
      var matches = controller.findMatches();
      if (matches.isEmpty) {
        controller.revertSwap(first, second);
        await _animations.swapTiles(
          firstTile,
          secondTile,
          _centerFor(firstTile.tile.row, firstTile.tile.col),
          _centerFor(secondTile.tile.row, secondTile.tile.col),
        );
        await _animations.shakeTiles([firstTile, secondTile]);
        controller.finishInteraction();
        interactionFinished = true;
        return const SwapResult.invalid();
      }

      controller.commitValidSwap();
      onBoardChanged();
      var cascade = 0;
      var scoreGained = 0;
      var clearedCount = 0;
      while (matches.isNotEmpty) {
        cascade++;
        controller.setInteractionState(
          cascade == 1
              ? BoardInteractionState.clearingMatch
              : BoardInteractionState.cascading,
        );
        final matchedTiles = controller.uniqueMatchedTiles(matches);
        final matchedComponents = [
          for (final tile in matchedTiles)
            if (_tiles[tile.id] case final TileComponent component) component,
        ];
        clearedCount += matchedTiles.length;
        final gained = controller.clearMatches(matches, cascade);
        scoreGained += gained;
        onBoardChanged();
        add(
          FloatingScoreComponent(
            label: cascade > 1 ? 'COMBO +$gained' : '+$gained',
            position: _centerOf(matchedComponents),
          ),
        );
        await _animations.popMatchedTiles(matchedComponents);
        for (final tile in matchedComponents) {
          _tiles.remove(tile.tile.id);
          tile.removeFromParent();
        }

        controller.setInteractionState(BoardInteractionState.applyingGravity);
        controller.applyGravity();
        await _animateTilesToTheirCells();

        controller.setInteractionState(BoardInteractionState.refilling);
        controller.refill();
        await _animateRefill();
        matches = controller.findMatches();
      }

      if (controller.ensurePlayableBoard()) {
        await _replaceAllTiles();
      }
      controller.finishInteraction();
      interactionFinished = true;
      onBoardChanged();
      return SwapResult(
        isValid: true,
        scoreGained: scoreGained,
        cascadeCount: cascade,
        clearedTiles: clearedCount,
      );
    } finally {
      if (!interactionFinished) {
        controller.finishInteraction();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final boardRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final panel = RRect.fromRectAndRadius(boardRect, const Radius.circular(34));
    canvas.drawShadow(
        Path()..addRRect(panel), const Color(0x1fa33467), 16, true);
    canvas.drawRRect(panel, Paint()..color = const Color(0xffffffff));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect.deflate(1.5),
        const Radius.circular(33),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xffffffff),
    );
  }

  Future<void> _buildInitialTiles() async {
    if (_tilesBuilt || _tileSize <= 0) {
      return;
    }
    _tilesBuilt = true;
    for (final tile in controller.board.tiles) {
      final component = TileComponent(
        tile: tile,
        tileSize: _tileSize,
        position: _centerFor(tile.row, tile.col),
      );
      _tiles[tile.id] = component;
      await add(component);
    }
  }

  Future<void> _animateTilesToTheirCells() async {
    final movements = <Future<void>>[];
    for (final tile in controller.board.tiles) {
      final component = _tiles[tile.id];
      if (component == null) {
        continue;
      }
      final destination = _centerFor(tile.row, tile.col);
      final distance = (component.position - destination).length;
      if (distance > .1) {
        movements.add(
          _animations.moveTile(
            component,
            destination,
            duration: math.min(.3, .1 + distance / _tileSize * .045),
          ),
        );
      }
    }
    await Future.wait(movements);
  }

  Future<void> _animateRefill() async {
    final movements = <Future<void>>[];
    for (final tile in controller.board.tiles) {
      if (_tiles.containsKey(tile.id)) {
        continue;
      }
      final destination = _centerFor(tile.row, tile.col);
      final component = TileComponent(
        tile: tile,
        tileSize: _tileSize,
        position: destination - Vector2(0, _tileSize * (tile.row + 1.4)),
      );
      _tiles[tile.id] = component;
      await add(component);
      movements.add(
        _animations.moveTile(
          component,
          destination,
          duration: .17 + tile.row * .018,
        ),
      );
    }
    await Future.wait(movements);
  }

  Future<void> _replaceAllTiles() async {
    for (final component in _tiles.values) {
      component.removeFromParent();
    }
    _tiles.clear();
    _tilesBuilt = false;
    await _buildInitialTiles();
  }

  TileComponent? _tileAt(BoardPosition position) {
    final tile = controller.board.tileAt(position.row, position.col);
    return tile == null ? null : _tiles[tile.id];
  }

  Vector2 _centerFor(int row, int col) {
    return Vector2(
      GameConfig.boardInnerPadding + (col + .5) * _tileSize,
      GameConfig.boardInnerPadding + (row + .5) * _tileSize,
    );
  }

  Vector2 _centerOf(List<TileComponent> tiles) {
    if (tiles.isEmpty) {
      return Vector2(size.x / 2, size.y / 2);
    }
    final total = tiles.fold<Vector2>(
      Vector2.zero(),
      (sum, tile) => sum + tile.position,
    );
    return total / tiles.length.toDouble();
  }

  BoardPosition? _positionFromLocal(Vector2 local) {
    if (_tileSize <= 0) {
      return null;
    }
    final boardLocal = local - Vector2.all(GameConfig.boardInnerPadding);
    final position = BoardPosition(
      row: (boardLocal.y / _tileSize).floor(),
      col: (boardLocal.x / _tileSize).floor(),
    );
    return _isInside(position) ? position : null;
  }

  bool _isInside(BoardPosition position) {
    return position.row >= 0 &&
        position.row < controller.board.rows &&
        position.col >= 0 &&
        position.col < controller.board.cols;
  }
}
