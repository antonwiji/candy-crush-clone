import 'dart:convert';

import 'package:flutter/services.dart';

import 'level_config.dart';

class LevelLoader {
  const LevelLoader();

  Future<LevelConfig> load(String assetPath) async {
    final source = await rootBundle.loadString(assetPath);
    return LevelConfig.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
