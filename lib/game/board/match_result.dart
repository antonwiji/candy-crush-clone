import '../tile/tile_model.dart';

class MatchResult {
  const MatchResult({
    required this.tiles,
    required this.isHorizontal,
    required this.isVertical,
  });

  final List<TileModel> tiles;
  final bool isHorizontal;
  final bool isVertical;
}
