enum TileType {
  red,
  blue,
  green,
  yellow,
  purple,
  orange;

  static TileType fromJson(String value) {
    return TileType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => throw FormatException('Unknown tile type: $value'),
    );
  }
}
