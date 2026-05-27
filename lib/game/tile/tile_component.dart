import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' show Alignment, LinearGradient;

import 'tile_model.dart';
import 'tile_type.dart';

class TileComponent extends PositionComponent implements OpacityProvider {
  TileComponent({
    required this.tile,
    required double tileSize,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(tileSize),
          anchor: Anchor.center,
        );

  final TileModel tile;
  bool isSelected = false;
  double _elapsed = 0;
  double _opacity = 1;

  @override
  double get opacity => _opacity;

  @override
  set opacity(double value) {
    _opacity = value.clamp(0, 1).toDouble();
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0) {
      return;
    }
    canvas.saveLayer(
      Rect.fromLTWH(-8, -8, size.x + 16, size.y + 16),
      Paint()..color = Color.fromRGBO(255, 255, 255, _opacity),
    );
    final rect = Rect.fromLTWH(
      size.x * .12,
      size.y * .12,
      size.x * .76,
      size.y * .76,
    );
    _drawTile(canvas, rect, tile.type);
    if (isSelected) {
      final pulse = 1.2 + (math.sin(_elapsed * 8) + 1) * 1.2;
      canvas.drawOval(
        rect.inflate(pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xffffffff),
      );
    }
    canvas.restore();
  }

  void _drawTile(Canvas canvas, Rect rect, TileType type) {
    final colors = switch (type) {
      TileType.red => const [Color(0xffff979a), Color(0xffe84c57)],
      TileType.blue => const [Color(0xff8bd5ff), Color(0xff2c8dcc)],
      TileType.green => const [Color(0xff83ebae), Color(0xff27ae70)],
      TileType.yellow => const [Color(0xffffdf65), Color(0xffd99b00)],
      TileType.purple => const [Color(0xffcf9aff), Color(0xff8443d2)],
      TileType.orange => const [Color(0xffffb45b), Color(0xffe27618)],
    };
    final shape = Path()..addOval(rect);
    canvas.drawShadow(shape, colors.last.withAlpha(80), 5, true);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(rect),
    );
    canvas.drawOval(
      Rect.fromLTWH(
        rect.left + rect.width * .2,
        rect.top + rect.height * .12,
        rect.width * .45,
        rect.height * .24,
      ),
      Paint()..color = const Color(0x8cffffff),
    );
    canvas.drawArc(
      rect.deflate(rect.width * .08),
      .38,
      2.25,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0x35ffffff),
    );
    _drawCandyMark(canvas, rect, type);
  }

  void _drawCandyMark(Canvas canvas, Rect rect, TileType type) {
    if (type == TileType.blue) {
      final center = rect.center;
      final w = rect.width * .43;
      final h = rect.height * .35;
      final diamond = Path()
        ..moveTo(center.dx, center.dy + h * .58)
        ..lineTo(center.dx - w * .62, center.dy - h * .25)
        ..lineTo(center.dx - w * .37, center.dy - h * .57)
        ..lineTo(center.dx + w * .37, center.dy - h * .57)
        ..lineTo(center.dx + w * .62, center.dy - h * .25)
        ..close();
      canvas.drawPath(
        diamond,
        Paint()
          ..color = const Color(0xffffffff)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(center.dx - w * .58, center.dy - h * .25),
        Offset(center.dx + w * .58, center.dy - h * .25),
        Paint()
          ..color = const Color(0xffffffff)
          ..strokeWidth = 1.4,
      );
    } else if (type == TileType.yellow) {
      final center = rect.center;
      final star = Path();
      for (var point = 0; point < 10; point++) {
        final radius = rect.width * (point.isEven ? .29 : .13);
        final angle = -math.pi / 2 + point * math.pi / 5;
        final offset = Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        );
        if (point == 0) {
          star.moveTo(offset.dx, offset.dy);
        } else {
          star.lineTo(offset.dx, offset.dy);
        }
      }
      star.close();
      canvas.drawPath(star, Paint()..color = const Color(0xffffffff));
    } else if (type == TileType.orange) {
      final dotPaint = Paint()..color = const Color(0x99a74908);
      for (final dot in const [
        Offset(-.18, -.12),
        Offset(.14, -.19),
        Offset(.17, .14),
        Offset(-.12, .17),
      ]) {
        canvas.drawCircle(
          Offset(
            rect.center.dx + rect.width * dot.dx,
            rect.center.dy + rect.height * dot.dy,
          ),
          rect.width * .045,
          dotPaint,
        );
      }
    }
  }
}
