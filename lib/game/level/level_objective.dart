import '../tile/tile_type.dart';

abstract class LevelObjective {
  const LevelObjective();

  factory LevelObjective.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'score':
        return ScoreObjective(targetScore: json['targetScore'] as int);
      case 'collect':
        final values = json['targetTiles'] as Map<String, dynamic>;
        return CollectObjective(
          targetTiles: values.map(
            (type, count) => MapEntry(TileType.fromJson(type), count as int),
          ),
        );
      default:
        throw FormatException('Unknown objective type: ${json['type']}');
    }
  }

  bool isComplete({required int score, required Map<TileType, int> collected});
  String label({required int score, required Map<TileType, int> collected});
}

class ScoreObjective extends LevelObjective {
  const ScoreObjective({required this.targetScore});

  final int targetScore;

  @override
  bool isComplete({required int score, required Map<TileType, int> collected}) {
    return score >= targetScore;
  }

  @override
  String label({required int score, required Map<TileType, int> collected}) {
    return 'Target: $targetScore';
  }
}

class CollectObjective extends LevelObjective {
  const CollectObjective({required this.targetTiles});

  final Map<TileType, int> targetTiles;

  @override
  bool isComplete({required int score, required Map<TileType, int> collected}) {
    return targetTiles.entries.every(
      (entry) => (collected[entry.key] ?? 0) >= entry.value,
    );
  }

  @override
  String label({required int score, required Map<TileType, int> collected}) {
    return targetTiles.entries
        .map((entry) => '${entry.key.name}: ${collected[entry.key] ?? 0}/${entry.value}')
        .join('  ');
  }
}
