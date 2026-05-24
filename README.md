# Sweet Match

MVP game match-3 orisinal berbasis Flutter dan Flame. Pemain memilih dua tile
bersebelahan untuk membuat match, meraih target skor, dan menyelesaikan level
sebelum moves habis.

## Fitur

- Board responsif 8x8 dengan enam tile berwarna yang digambar langsung.
- Swap tervalidasi, deteksi match horizontal/vertical, cascade, gravity, refill.
- Papan awal bebas match dan selalu memiliki kemungkinan move.
- Level JSON, skor, moves, score objective, menu, HUD, pause, win, dan lose.
- Logic board terpisah dari rendering dengan unit test.

## Menjalankan

Project ini memerlukan Flutter SDK yang sesuai dengan `pubspec.yaml`.

```bash
flutter pub get
flutter test
flutter run
```

Level awal dapat diedit di `assets/levels/level_001.json`.
