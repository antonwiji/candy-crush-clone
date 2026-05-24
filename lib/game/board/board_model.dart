import '../tile/tile_model.dart';
import '../tile/tile_type.dart';

class BoardModel {
  BoardModel.empty({required this.rows, required this.cols})
      : cells = List.generate(
          rows,
          (_) => List<TileModel?>.filled(cols, null),
        );

  final int rows;
  final int cols;
  final List<List<TileModel?>> cells;

  TileModel? tileAt(int row, int col) => cells[row][col];

  void put(int row, int col, TileModel? tile) {
    cells[row][col] = tile;
    if (tile != null) {
      tile
        ..row = row
        ..col = col;
    }
  }

  Iterable<TileModel> get tiles sync* {
    for (final row in cells) {
      for (final tile in row) {
        if (tile != null) {
          yield tile;
        }
      }
    }
  }

  factory BoardModel.fromTypes(List<List<TileType>> types) {
    final board = BoardModel.empty(rows: types.length, cols: types.first.length);
    var id = 0;
    for (var row = 0; row < board.rows; row++) {
      for (var col = 0; col < board.cols; col++) {
        board.put(
          row,
          col,
          TileModel(
            id: 'fixture_${id++}',
            type: types[row][col],
            row: row,
            col: col,
          ),
        );
      }
    }
    return board;
  }
}
