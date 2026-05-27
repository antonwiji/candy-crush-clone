import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../tile/tile_component.dart';

class TileAnimationService {
  Future<void> moveTile(
    TileComponent tile,
    Vector2 destination, {
    double duration = .15,
  }) {
    final completer = Completer<void>();
    tile.add(
      MoveEffect.to(
        destination,
        EffectController(duration: duration, curve: Curves.easeOutCubic),
        onComplete: completer.complete,
      ),
    );
    return completer.future;
  }

  Future<void> swapTiles(
    TileComponent first,
    TileComponent second,
    Vector2 firstDestination,
    Vector2 secondDestination,
  ) {
    return Future.wait([
      moveTile(first, firstDestination),
      moveTile(second, secondDestination),
    ]);
  }

  Future<void> shakeTiles(List<TileComponent> tiles) async {
    final origins = {for (final tile in tiles) tile: tile.position.clone()};
    for (final delta in const [-4.0, 7.0, -5.0, 2.0]) {
      await Future.wait([
        for (final tile in tiles)
          moveTile(
            tile,
            origins[tile]! + Vector2(delta, 0),
            duration: .04,
          ),
      ]);
    }
    await Future.wait([
      for (final tile in tiles) moveTile(tile, origins[tile]!, duration: .04),
    ]);
  }

  Future<void> popMatchedTiles(List<TileComponent> tiles) {
    return Future.wait(tiles.map(_popTile));
  }

  Future<void> _popTile(TileComponent tile) {
    final completer = Completer<void>();
    tile.add(
      ScaleEffect.to(
        Vector2.all(1.16),
        EffectController(duration: .1, curve: Curves.easeOut),
        onComplete: () {
          tile
            ..add(
              ScaleEffect.to(
                Vector2.all(.25),
                EffectController(duration: .18, curve: Curves.easeInCubic),
              ),
            )
            ..add(
              OpacityEffect.fadeOut(
                EffectController(duration: .18, curve: Curves.easeIn),
                onComplete: completer.complete,
              ),
            );
        },
      ),
    );
    return completer.future;
  }
}
