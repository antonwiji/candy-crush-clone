class LevelTemplate {
  const LevelTemplate({
    required this.templateId,
    required this.baseTargetScore,
    required this.baseMoves,
    required this.boardRows,
    required this.boardColumns,
    required this.baseTileVariantCount,
    this.specialRules = const [],
  });

  final int templateId;
  final int baseTargetScore;
  final int baseMoves;
  final int boardRows;
  final int boardColumns;
  final int baseTileVariantCount;
  final List<String> specialRules;
}
