import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors;

import '../game_config.dart';
import '../tile/tile_type.dart';
import 'board_controller.dart';
import 'board_position.dart';

class BoardComponent extends PositionComponent with TapCallbacks {
  BoardComponent({
    required this.controller,
    required this.onTilePressed,
  });

  final BoardController controller;
  final void Function(BoardPosition position) onTilePressed;
  BoardPosition? selected;
  double _elapsed = 0;
  double _tileSize = 0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final availableWidth = size.x - GameConfig.boardPadding * 2;
    final availableHeight =
        size.y - GameConfig.boardTop - GameConfig.boardBottomPadding;
    _tileSize = math.min(
      availableWidth / controller.board.cols,
      availableHeight / controller.board.rows,
    );
    this.size = Vector2(
      _tileSize * controller.board.cols,
      _tileSize * controller.board.rows,
    );
    position = Vector2((size.x - this.size.x) / 2, GameConfig.boardTop);
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_tileSize <= 0) {
      return;
    }
    final col = (event.localPosition.x / _tileSize).floor();
    final row = (event.localPosition.y / _tileSize).floor();
    if (row >= 0 &&
        row < controller.board.rows &&
        col >= 0 &&
        col < controller.board.cols) {
      onTilePressed(BoardPosition(row: row, col: col));
    }
  }

  @override
  void render(Canvas canvas) {
    final boardRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(24)),
      Paint()..color = const Color(0x55ffffff),
    );

    for (var row = 0; row < controller.board.rows; row++) {
      for (var col = 0; col < controller.board.cols; col++) {
        final cell = Rect.fromLTWH(
          col * _tileSize + 2,
          row * _tileSize + 2,
          _tileSize - 4,
          _tileSize - 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cell, Radius.circular(_tileSize * 0.2)),
          Paint()..color = const Color(0x16ffffff),
        );
        final tile = controller.board.tileAt(row, col);
        if (tile != null) {
          _drawTile(canvas, cell.deflate(_tileSize * 0.1), tile.type);
        }
      }
    }

    final active = selected;
    if (active != null) {
      final pulse = 2 + (math.sin(_elapsed * 8) + 1) * 1.5;
      final rect = Rect.fromLTWH(
        active.col * _tileSize + pulse,
        active.row * _tileSize + pulse,
        _tileSize - pulse * 2,
        _tileSize - pulse * 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(_tileSize * 0.25)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white,
      );
    }
  }

  void _drawTile(Canvas canvas, Rect rect, TileType type) {
    final color = switch (type) {
      TileType.red => const Color(0xffff5573),
      TileType.blue => const Color(0xff45b8ff),
      TileType.green => const Color(0xff48db91),
      TileType.yellow => const Color(0xffffd34d),
      TileType.purple => const Color(0xffaa76ff),
      TileType.orange => const Color(0xffff964a),
    };
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.38));
    canvas.drawShadow(
      Path()..addRRect(shape),
      const Color(0x66000000),
      3,
      false,
    );
    canvas.drawRRect(shape, Paint()..color = color);
    canvas.drawOval(
      Rect.fromLTWH(
        rect.left + rect.width * 0.2,
        rect.top + rect.height * 0.14,
        rect.width * 0.38,
        rect.height * 0.2,
      ),
      Paint()..color = const Color(0x66ffffff),
    );
  }
}
