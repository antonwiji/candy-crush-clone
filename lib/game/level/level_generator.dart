import 'generated_level_config.dart';
import 'level_template.dart';

class LevelGenerator {
  const LevelGenerator({
    required this.templates,
    this.maxTileVariantCount = 6,
  });

  final List<LevelTemplate> templates;
  final int maxTileVariantCount;

  GeneratedLevelConfig generate(int levelNumber) {
    if (levelNumber <= 0) {
      throw ArgumentError.value(
        levelNumber,
        'levelNumber',
        'must be greater than 0',
      );
    }
    if (templates.isEmpty) {
      throw StateError('LevelGenerator requires at least one template.');
    }

    final totalTemplates = templates.length;
    final templateIndex = (levelNumber - 1) % totalTemplates;
    final difficultyTier = ((levelNumber - 1) ~/ totalTemplates) + 1;
    final template = templates[templateIndex];

    return GeneratedLevelConfig(
      levelNumber: levelNumber,
      templateId: template.templateId,
      difficultyTier: difficultyTier,
      targetScore: _calculateTargetScore(
        template.baseTargetScore,
        levelNumber,
        difficultyTier,
      ),
      moves: _calculateMoves(template.baseMoves, difficultyTier),
      boardRows: template.boardRows,
      boardColumns: template.boardColumns,
      tileVariantCount: _calculateTileVariantCount(
        template.baseTileVariantCount,
        difficultyTier,
      ),
      obstacleCount: _calculateObstacleCount(levelNumber, difficultyTier),
      rewardCoin: _calculateRewardCoin(difficultyTier),
    );
  }

  int _calculateTargetScore(
    int baseTargetScore,
    int levelNumber,
    int difficultyTier,
  ) {
    final levelBonus = levelNumber * 80;
    final tierBonus = (difficultyTier - 1) * 500;
    return baseTargetScore + levelBonus + tierBonus;
  }

  int _calculateMoves(int baseMoves, int difficultyTier) {
    final reducedMoves = baseMoves - ((difficultyTier - 1) * 2);
    return reducedMoves.clamp(12, baseMoves);
  }

  int _calculateTileVariantCount(
    int baseTileVariantCount,
    int difficultyTier,
  ) {
    final addedVariant = difficultyTier >= 2 ? 1 : 0;
    final result = baseTileVariantCount + addedVariant;
    return result.clamp(5, maxTileVariantCount);
  }

  int _calculateObstacleCount(int levelNumber, int difficultyTier) {
    if (levelNumber < 6) {
      return 0;
    }
    final count = difficultyTier + (levelNumber ~/ 10);
    return count.clamp(0, 12);
  }

  int _calculateRewardCoin(int difficultyTier) {
    return 5 + ((difficultyTier - 1) * 2);
  }
}
