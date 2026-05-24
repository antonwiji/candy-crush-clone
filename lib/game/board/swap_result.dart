class SwapResult {
  const SwapResult({
    required this.isValid,
    this.scoreGained = 0,
    this.cascadeCount = 0,
    this.clearedTiles = 0,
  });

  const SwapResult.invalid() : this(isValid: false);

  final bool isValid;
  final int scoreGained;
  final int cascadeCount;
  final int clearedTiles;
}
