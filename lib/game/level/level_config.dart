import '../tile/tile_type.dart';
import 'level_objective.dart';

class LevelConfig {
  const LevelConfig({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.moves,
    required this.tileTypes,
    required this.objective,
  });

  final int id;
  final String name;
  final int rows;
  final int cols;
  final int moves;
  final List<TileType> tileTypes;
  final LevelObjective objective;

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    return LevelConfig(
      id: json['id'] as int,
      name: json['name'] as String,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      moves: json['moves'] as int,
      tileTypes: (json['tileTypes'] as List<dynamic>)
          .cast<String>()
          .map(TileType.fromJson)
          .toList(),
      objective: LevelObjective.fromJson(json['objective'] as Map<String, dynamic>),
    );
  }
}
