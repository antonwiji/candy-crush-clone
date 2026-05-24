class BoardPosition {
  const BoardPosition({required this.row, required this.col});

  final int row;
  final int col;

  bool isAdjacentTo(BoardPosition other) {
    return (row - other.row).abs() + (col - other.col).abs() == 1;
  }

  @override
  bool operator ==(Object other) {
    return other is BoardPosition && row == other.row && col == other.col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}
