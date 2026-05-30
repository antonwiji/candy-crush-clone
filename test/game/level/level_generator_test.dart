import 'package:flutter_test/flutter_test.dart';
import 'package:sweet_match_game/game/level/level_config.dart';
import 'package:sweet_match_game/game/level/level_generator.dart';
import 'package:sweet_match_game/game/level/level_templates.dart';

void main() {
  group('LevelGenerator', () {
    const generator = LevelGenerator(templates: levelTemplates);

    test('level 1 uses the first template and tier 1', () {
      final level = generator.generate(1);

      expect(level.templateId, 1);
      expect(level.difficultyTier, 1);
      expect(level.targetScore, 1080);
    });

    test('level 10 uses the tenth template and tier 1', () {
      final level = generator.generate(10);

      expect(level.templateId, 10);
      expect(level.difficultyTier, 1);
    });

    test('level 11 loops to the first template and tier 2', () {
      final level = generator.generate(11);

      expect(level.templateId, 1);
      expect(level.difficultyTier, 2);
      expect(level.targetScore, greaterThan(generator.generate(1).targetScore));
    });

    test('difficulty increases for later loops', () {
      final level11 = generator.generate(11);
      final level21 = generator.generate(21);

      expect(level21.difficultyTier, greaterThan(level11.difficultyTier));
      expect(level21.targetScore, greaterThan(level11.targetScore));
    });

    test('moves never go below the minimum', () {
      final highLevel = generator.generate(500);

      expect(highLevel.moves, greaterThanOrEqualTo(12));
    });

    test('high level config can be converted to playable LevelConfig', () {
      final generated = generator.generate(500);
      final level = LevelConfig.fromGenerated(generated);

      expect(level.id, 500);
      expect(level.rows, 8);
      expect(level.cols, 8);
      expect(level.objective, isNotNull);
      expect(level.tileTypes.length, generated.tileVariantCount);
    });
  });
}
