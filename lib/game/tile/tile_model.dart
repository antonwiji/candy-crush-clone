import 'special_tile_type.dart';
import 'tile_type.dart';

class TileModel {
  TileModel({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    this.specialType = SpecialTileType.none,
    this.isMatched = false,
    this.isFalling = false,
    this.isLocked = false,
  });

  final String id;
  TileType type;
  SpecialTileType specialType;
  int row;
  int col;
  bool isMatched;
  bool isFalling;
  bool isLocked;
}
