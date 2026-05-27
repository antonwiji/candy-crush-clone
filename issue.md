# issue.md — Feature Animasi Gameplay Match-3

> **Project:** Sweet Match  
> **Engine:** Flutter + Flame  
> **Jenis issue:** Feature / Gameplay Animation  
> **Prioritas:** High  
> **Target modul:** Gameplay board, tile animation, scoring feedback  
> **Status:** Draft untuk development  

---

## 1. Judul Issue

Menambahkan animasi slide bidak, valid/invalid swap adjustment, dan animasi point ketika bidak berhasil match.

---

## 2. Ringkasan

Saat ini gameplay match-3 membutuhkan feedback visual yang lebih menarik agar pemain merasa aksi swap, match, dan perolehan skor terasa responsif. Feature ini bertujuan menambahkan animasi utama pada gameplay:

1. **Animasi slide bidak** ketika pemain menukar dua bidak.
2. **Adjustment animasi swap valid** ketika swap menghasilkan match.
3. **Adjustment animasi swap invalid** ketika swap tidak menghasilkan match dan bidak harus kembali ke posisi awal.
4. **Animasi bidak mendapatkan point** saat match berhasil.
5. **Floating score text** seperti `+30`, `+50`, atau `Combo +120` di area tile yang match.
6. **Pop/scale/fade animation** saat bidak hilang setelah menghasilkan point.

Fitur ini akan meningkatkan feel game agar lebih halus, satisfying, dan mendekati standar casual puzzle game modern.

---

## 3. Tujuan Feature

### 3.1 Tujuan Utama

Membuat interaksi gameplay terasa lebih hidup melalui animasi yang halus dan mudah dipahami oleh pemain.

### 3.2 Tujuan Teknis

- Memisahkan logic board dan visual animation agar kode tetap rapi.
- Mencegah input baru ketika animasi sedang berjalan.
- Menyediakan pondasi reusable untuk animasi tile, score, combo, dan special effect.
- Menggunakan sistem `Effect` dari Flame untuk animasi posisi, scale, opacity, dan sequence.

---

## 4. Latar Belakang Masalah

Game match-3 sangat bergantung pada feedback visual. Jika bidak langsung berpindah, langsung hilang, atau skor langsung berubah tanpa animasi, game akan terasa kaku.

Masalah yang perlu diselesaikan:

- Swap bidak masih terasa instan.
- Pemain belum mendapat feedback jelas apakah swap valid atau invalid.
- Saat tile match, belum ada efek visual yang membuat pemain merasa mendapat reward.
- Skor bertambah, tetapi belum ada visual point di area board.
- Belum ada sistem penguncian input selama animasi berlangsung.

---

## 5. Scope Pekerjaan

### 5.1 Termasuk Dalam Scope

- Animasi tile bergerak dari cell awal ke cell tujuan.
- Animasi tile kembali jika swap tidak valid.
- Animasi tile match berupa scale up, pop, fade out, lalu remove.
- Floating score text di atas tile yang match.
- Particle ringan opsional ketika match terjadi.
- Board input lock selama animasi berjalan.
- Callback setelah animasi selesai untuk melanjutkan flow game:
  - cek match,
  - remove tile,
  - apply gravity,
  - refill tile,
  - cek cascade/combo.

### 5.2 Tidak Termasuk Dalam Scope

- Booster kompleks seperti bomb, rocket, rainbow candy.
- Animasi special tile chain reaction.
- Animasi level complete penuh.
- Audio SFX final.
- Haptic feedback.
- Skin/tema dinamis.
- Asset final production.

---

## 6. User Story

Sebagai pemain, saya ingin melihat bidak bergerak dengan halus ketika saya melakukan slide/swap, lalu mendapatkan animasi point yang menarik ketika bidak berhasil match, sehingga gameplay terasa menyenangkan, jelas, dan memuaskan.

---

## 7. Acceptance Criteria

Feature dianggap selesai jika memenuhi kriteria berikut:

### 7.1 Animasi Slide Bidak

- Ketika pemain swipe bidak ke arah bidak sebelah, dua bidak bergerak saling bertukar posisi.
- Animasi slide berdurasi sekitar `120ms - 180ms`.
- Pergerakan terasa smooth menggunakan easing.
- Bidak tidak teleport secara instan.
- Selama animasi swap berjalan, input pemain dikunci.

### 7.2 Swap Valid

- Jika swap menghasilkan match, posisi bidak tetap pada posisi hasil swap.
- Setelah animasi swap selesai, sistem menjalankan deteksi match.
- Tile yang match menjalankan animasi point/pop/fade.
- Skor bertambah setelah atau bersamaan dengan animasi point.

### 7.3 Swap Invalid

- Jika swap tidak menghasilkan match, bidak tetap melakukan slide terlebih dahulu.
- Setelah diketahui invalid, dua bidak kembali ke posisi semula.
- Animasi return berdurasi sekitar `120ms - 180ms`.
- Tambahkan efek kecil seperti shake atau bounce ringan agar pemain tahu swap tidak valid.
- Move tidak berkurang jika swap invalid.

### 7.4 Animasi Point Saat Match

- Tile yang match melakukan efek:
  - scale up singkat,
  - pop/shrink,
  - fade out,
  - remove dari board.
- Muncul floating text di area match, contoh:
  - `+30`
  - `+50`
  - `Combo +120`
- Floating text bergerak naik dan fade out.
- Floating text otomatis dihapus setelah animasi selesai.

### 7.5 Flow Board Tetap Aman

- Tidak boleh ada input baru selama proses:
  - swap,
  - invalid return,
  - match clear,
  - gravity,
  - refill,
  - cascade.
- State board model harus tetap sinkron dengan posisi visual tile.
- Tidak boleh ada tile yang tertinggal di posisi salah setelah animasi selesai.
- Tidak boleh ada double scoring dari match yang sama.

---

## 8. Rekomendasi Durasi Animasi

| Animasi | Durasi | Catatan |
|---|---:|---|
| Slide swap | 0.12s - 0.18s | Cepat dan responsif |
| Invalid swap return | 0.12s - 0.18s | Bisa ditambah shake kecil |
| Match pop | 0.10s - 0.15s | Scale up sedikit |
| Match fade out | 0.15s - 0.25s | Setelah pop |
| Floating score | 0.50s - 0.80s | Naik dan fade out |
| Gravity fall per row | 0.08s - 0.12s | Bisa stagger per jarak jatuh |
| Refill tile spawn | 0.10s - 0.20s | Dari atas board |

---

## 9. Desain Teknis

### 9.1 Komponen yang Terlibat

```text
lib/game/
├── board/
│   ├── board_component.dart
│   ├── board_controller.dart
│   ├── board_model.dart
│   ├── board_position.dart
│   └── match_result.dart
│
├── tile/
│   ├── tile_component.dart
│   ├── tile_model.dart
│   └── tile_type.dart
│
├── effects/
│   ├── tile_animation_service.dart
│   ├── tile_slide_effect.dart
│   ├── tile_invalid_swap_effect.dart
│   ├── tile_match_pop_effect.dart
│   ├── floating_score_component.dart
│   └── match_particle_component.dart
│
└── sweet_match_game.dart
```

---

## 10. State Baru yang Dibutuhkan

Tambahkan state untuk mengatur apakah board sedang menerima input atau sedang menjalankan animasi.

```dart
enum BoardInteractionState {
  idle,
  swapping,
  revertingSwap,
  clearingMatch,
  applyingGravity,
  refilling,
  cascading,
}
```

Contoh penggunaan:

```dart
bool get canAcceptInput => interactionState == BoardInteractionState.idle;
```

Saat animasi dimulai:

```dart
interactionState = BoardInteractionState.swapping;
```

Saat semua animasi selesai:

```dart
interactionState = BoardInteractionState.idle;
```

---

## 11. Alur Gameplay Baru

### 11.1 Alur Swap Valid

```text
User swipe tile
↓
Board lock input
↓
Run slide animation between tile A and tile B
↓
Update board model position
↓
Check match
↓
If match exists:
  - reduce move
  - calculate score
  - play match pop animation
  - show floating score
  - remove matched tiles
  - apply gravity animation
  - refill animation
  - check cascade
↓
Board unlock input
```

### 11.2 Alur Swap Invalid

```text
User swipe tile
↓
Board lock input
↓
Run slide animation between tile A and tile B
↓
Temporarily update/check board model
↓
If no match:
  - run return slide animation
  - optional shake/bounce effect
  - restore board model position
  - do not reduce move
↓
Board unlock input
```

---

## 12. Detail Implementasi Animasi

### 12.1 Animasi Slide Bidak

Gunakan `MoveEffect.to` untuk menggerakkan `TileComponent` dari posisi saat ini ke posisi cell tujuan.

Contoh konsep:

```dart
Future<void> animateTileMove({
  required TileComponent tile,
  required Vector2 targetPosition,
  double duration = 0.15,
}) {
  final completer = Completer<void>();

  tile.add(
    MoveEffect.to(
      targetPosition,
      EffectController(
        duration: duration,
        curve: Curves.easeOutCubic,
      ),
      onComplete: () {
        completer.complete();
      },
    ),
  );

  return completer.future;
}
```

---

### 12.2 Animasi Swap Dua Bidak

```dart
Future<void> animateSwap({
  required TileComponent firstTile,
  required TileComponent secondTile,
  required Vector2 firstTarget,
  required Vector2 secondTarget,
}) async {
  await Future.wait([
    animateTileMove(
      tile: firstTile,
      targetPosition: firstTarget,
    ),
    animateTileMove(
      tile: secondTile,
      targetPosition: secondTarget,
    ),
  ]);
}
```

---

### 12.3 Animasi Invalid Swap Return

Jika swap tidak menghasilkan match, gunakan `animateSwap` lagi untuk mengembalikan tile ke posisi awal.

Tambahkan efek shake opsional setelah tile kembali.

```dart
Future<void> animateInvalidSwap({
  required TileComponent firstTile,
  required TileComponent secondTile,
  required Vector2 firstOriginalPosition,
  required Vector2 secondOriginalPosition,
}) async {
  await animateSwap(
    firstTile: firstTile,
    secondTile: secondTile,
    firstTarget: firstOriginalPosition,
    secondTarget: secondOriginalPosition,
  );

  await Future.wait([
    animateSmallShake(firstTile),
    animateSmallShake(secondTile),
  ]);
}
```

Contoh shake kecil:

```dart
Future<void> animateSmallShake(TileComponent tile) {
  final completer = Completer<void>();
  final original = tile.position.clone();

  tile.add(
    SequenceEffect([
      MoveEffect.to(
        original + Vector2(4, 0),
        EffectController(duration: 0.04),
      ),
      MoveEffect.to(
        original + Vector2(-4, 0),
        EffectController(duration: 0.04),
      ),
      MoveEffect.to(
        original,
        EffectController(duration: 0.04),
      ),
    ], onComplete: () {
      completer.complete();
    }),
  );

  return completer.future;
}
```

---

### 12.4 Animasi Tile Match Pop + Fade

Ketika tile match, jalankan efek visual sebelum tile dihapus.

Konsep animasi:

```text
Tile scale 1.0 → 1.18
Tile scale 1.18 → 0.0
Tile opacity 1.0 → 0.0
Remove tile from parent
```

Contoh implementasi:

```dart
Future<void> animateMatchPop(TileComponent tile) {
  final completer = Completer<void>();

  tile.add(
    SequenceEffect([
      ScaleEffect.to(
        Vector2.all(1.18),
        EffectController(
          duration: 0.10,
          curve: Curves.easeOutBack,
        ),
      ),
      ScaleEffect.to(
        Vector2.all(0.0),
        EffectController(
          duration: 0.18,
          curve: Curves.easeInBack,
        ),
      ),
    ], onComplete: () {
      tile.removeFromParent();
      completer.complete();
    }),
  );

  return completer.future;
}
```

Catatan:

- Jika `OpacityEffect` digunakan, pastikan `TileComponent` mendukung perubahan opacity.
- Jika memakai sprite biasa, opsi paling aman adalah scale down lalu remove.
- Untuk efek lebih halus, gunakan kombinasi scale, opacity, dan particle ringan.

---

## 13. Floating Score Component

Buat component baru untuk text skor yang muncul di atas board.

### 13.1 Lokasi File

```text
lib/game/effects/floating_score_component.dart
```

### 13.2 Contoh Component

```dart
class FloatingScoreComponent extends TextComponent {
  FloatingScoreComponent({
    required String text,
    required Vector2 position,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      MoveEffect.by(
        Vector2(0, -36),
        EffectController(
          duration: 0.65,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    add(
      OpacityEffect.fadeOut(
        EffectController(
          duration: 0.65,
          curve: Curves.easeOut,
        ),
        onComplete: removeFromParent,
      ),
    );
  }
}
```

### 13.3 Cara Memanggil

```dart
void showFloatingScore({
  required int score,
  required Vector2 worldPosition,
}) {
  boardComponent.add(
    FloatingScoreComponent(
      text: '+$score',
      position: worldPosition,
    ),
  );
}
```

---

## 14. Perhitungan Point Awal

Untuk MVP animasi point, gunakan scoring sederhana terlebih dahulu.

```dart
int calculateMatchScore(int matchedTileCount, int comboIndex) {
  final baseScore = matchedTileCount * 10;
  final comboBonus = comboIndex <= 1 ? 0 : comboIndex * 20;
  return baseScore + comboBonus;
}
```

Contoh:

| Match | Combo | Score |
|---|---:|---:|
| 3 tile | 1 | 30 |
| 4 tile | 1 | 40 |
| 5 tile | 1 | 50 |
| 3 tile | 2 | 70 |
| 4 tile | 3 | 100 |

---

## 15. Posisi Floating Score

Floating score sebaiknya muncul di titik tengah kumpulan tile yang match.

Contoh helper:

```dart
Vector2 calculateMatchCenter(List<TileComponent> matchedTiles) {
  final total = matchedTiles.fold<Vector2>(
    Vector2.zero(),
    (sum, tile) => sum + tile.position,
  );

  return total / matchedTiles.length.toDouble();
}
```

---

## 16. Tile Animation Service

Agar `BoardController` tidak terlalu penuh, buat service khusus animasi.

### 16.1 Lokasi File

```text
lib/game/effects/tile_animation_service.dart
```

### 16.2 Tanggung Jawab

`TileAnimationService` bertugas untuk:

- menjalankan animasi swap,
- menjalankan invalid swap return,
- menjalankan tile pop,
- menjalankan gravity fall,
- menjalankan refill spawn,
- menampilkan floating score,
- mengembalikan `Future<void>` agar board flow bisa menunggu animasi selesai.

### 16.3 Contoh Skeleton

```dart
class TileAnimationService {
  Future<void> swapTiles({
    required TileComponent firstTile,
    required TileComponent secondTile,
    required Vector2 firstTarget,
    required Vector2 secondTarget,
  }) async {
    await Future.wait([
      moveTile(firstTile, firstTarget),
      moveTile(secondTile, secondTarget),
    ]);
  }

  Future<void> moveTile(
    TileComponent tile,
    Vector2 targetPosition, {
    double duration = 0.15,
  }) {
    final completer = Completer<void>();

    tile.add(
      MoveEffect.to(
        targetPosition,
        EffectController(
          duration: duration,
          curve: Curves.easeOutCubic,
        ),
        onComplete: completer.complete,
      ),
    );

    return completer.future;
  }

  Future<void> popMatchedTiles(List<TileComponent> tiles) async {
    await Future.wait(
      tiles.map(animateMatchedTile),
    );
  }

  Future<void> animateMatchedTile(TileComponent tile) {
    final completer = Completer<void>();

    tile.add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.15),
          EffectController(duration: 0.10, curve: Curves.easeOutBack),
        ),
        ScaleEffect.to(
          Vector2.all(0.0),
          EffectController(duration: 0.18, curve: Curves.easeInBack),
        ),
      ], onComplete: () {
        tile.removeFromParent();
        completer.complete();
      }),
    );

    return completer.future;
  }
}
```

---

## 17. Integrasi dengan Board Controller

Contoh flow di `BoardController`:

```dart
Future<void> handleTileSwipe({
  required BoardPosition from,
  required BoardPosition to,
}) async {
  if (!canAcceptInput) return;

  interactionState = BoardInteractionState.swapping;

  final firstTile = boardModel.getTileComponent(from);
  final secondTile = boardModel.getTileComponent(to);

  final firstOriginalPosition = firstTile.position.clone();
  final secondOriginalPosition = secondTile.position.clone();

  await animationService.swapTiles(
    firstTile: firstTile,
    secondTile: secondTile,
    firstTarget: secondOriginalPosition,
    secondTarget: firstOriginalPosition,
  );

  boardModel.swap(from, to);

  final matches = matchDetector.findMatches(boardModel);

  if (matches.isEmpty) {
    interactionState = BoardInteractionState.revertingSwap;

    await animationService.swapTiles(
      firstTile: firstTile,
      secondTile: secondTile,
      firstTarget: firstOriginalPosition,
      secondTarget: secondOriginalPosition,
    );

    boardModel.swap(to, from);
    interactionState = BoardInteractionState.idle;
    return;
  }

  await processMatches(matches);

  interactionState = BoardInteractionState.idle;
}
```

---

## 18. Integrasi Process Match

```dart
Future<void> processMatches(List<MatchResult> matches) async {
  interactionState = BoardInteractionState.clearingMatch;

  final matchedTiles = matches.expand((match) => match.tiles).toList();
  final score = calculateMatchScore(matchedTiles.length, currentComboIndex);
  final center = calculateMatchCenter(matchedTiles);

  gameScore += score;

  animationService.showFloatingScore(
    score: score,
    position: center,
  );

  await animationService.popMatchedTiles(matchedTiles);

  boardModel.removeTiles(matchedTiles);

  interactionState = BoardInteractionState.applyingGravity;
  await applyGravityWithAnimation();

  interactionState = BoardInteractionState.refilling;
  await refillBoardWithAnimation();

  final nextMatches = matchDetector.findMatches(boardModel);
  if (nextMatches.isNotEmpty) {
    currentComboIndex++;
    interactionState = BoardInteractionState.cascading;
    await processMatches(nextMatches);
  } else {
    currentComboIndex = 1;
  }
}
```

---

## 19. Animasi Gravity dan Refill

Walaupun issue utama adalah slide dan point, gravity/refill harus ikut diperhatikan agar flow visual tidak patah.

### 19.1 Gravity

- Tile yang berada di atas slot kosong turun ke bawah.
- Durasi animasi bisa menyesuaikan jarak jatuh.
- Semakin jauh jatuh, durasi sedikit lebih lama.

Contoh formula durasi:

```dart
double calculateFallDuration(int distance) {
  return 0.08 + (distance * 0.04);
}
```

### 19.2 Refill

- Tile baru muncul dari atas board.
- Tile bergerak turun ke slot kosong.
- Bisa ditambah scale dari `0.8` ke `1.0` agar terasa muncul.

---

## 20. Particle Ringan Opsional

Untuk membuat animasi point lebih menarik, tambahkan particle ringan ketika match.

Contoh konsep:

```text
Saat tile match:
- muncul 6–10 partikel kecil,
- partikel menyebar sedikit,
- fade out dalam 0.3s - 0.5s,
- warna mengikuti tipe tile.
```

Catatan:

- Particle tidak wajib untuk MVP pertama.
- Jangan terlalu banyak particle agar performa Android tetap aman.
- Batasi particle maksimal per match, misalnya 30 particle per cascade.

---

## 21. Asset yang Dibutuhkan

### 21.1 Wajib

- Tile sprite untuk setiap bidak.
- Font tebal untuk floating score.
- SFX sementara untuk match dan invalid swap.

### 21.2 Opsional

- Particle sparkle kecil.
- Glow asset.
- Combo badge.
- Star burst sprite.

---

## 22. Risiko Teknis

| Risiko | Dampak | Solusi |
|---|---|---|
| Input bisa masuk saat animasi berjalan | Board rusak / tile overlap | Gunakan `BoardInteractionState` |
| Board model dan posisi visual tidak sinkron | Match detection salah | Update model hanya di titik flow yang jelas |
| Banyak efek berjalan bersamaan | FPS turun | Batasi particle dan gunakan durasi pendek |
| Tile dihapus sebelum animasi selesai | Animasi terpotong | Remove tile hanya pada `onComplete` |
| Cascade memicu score ganda | Score tidak akurat | Tandai match yang sudah diproses |

---

## 23. Checklist Development

### 23.1 Setup

- [ ] Buat folder `lib/game/effects/`.
- [ ] Buat file `tile_animation_service.dart`.
- [ ] Buat file `floating_score_component.dart`.
- [ ] Tambahkan enum `BoardInteractionState`.
- [ ] Tambahkan property `interactionState` di `BoardController`.

### 23.2 Animasi Swap

- [ ] Implementasi `moveTile()`.
- [ ] Implementasi `swapTiles()`.
- [ ] Integrasi swap animation dengan swipe input.
- [ ] Lock input saat swap berjalan.
- [ ] Unlock input setelah flow selesai.

### 23.3 Invalid Swap

- [ ] Deteksi swap tanpa match.
- [ ] Jalankan animasi return.
- [ ] Tambahkan shake/bounce kecil.
- [ ] Pastikan move tidak berkurang.
- [ ] Pastikan board model kembali seperti semula.

### 23.4 Match Point Animation

- [ ] Implementasi `animateMatchedTile()`.
- [ ] Implementasi scale pop.
- [ ] Implementasi remove tile setelah animasi selesai.
- [ ] Implementasi `FloatingScoreComponent`.
- [ ] Floating score muncul di tengah area match.
- [ ] Floating score bergerak naik dan fade out.

### 23.5 Gravity dan Refill

- [ ] Gravity menunggu match animation selesai.
- [ ] Tile jatuh menggunakan move animation.
- [ ] Tile baru spawn dari atas.
- [ ] Board model sinkron setelah gravity/refill.

### 23.6 Testing

- [ ] Test swap valid horizontal.
- [ ] Test swap valid vertical.
- [ ] Test swap invalid.
- [ ] Test match 3 tile.
- [ ] Test match 4 tile.
- [ ] Test cascade/combo.
- [ ] Test input spam saat animasi berjalan.
- [ ] Test performa di Android device/emulator.

---

## 24. Definition of Done

Issue ini dianggap selesai jika:

- [ ] Swap tile sudah memiliki animasi slide yang halus.
- [ ] Swap invalid memiliki animasi balik ke posisi awal.
- [ ] Match tile memiliki animasi pop/remove.
- [ ] Floating score muncul saat tile menghasilkan point.
- [ ] Input terkunci selama animasi berjalan.
- [ ] Board model dan posisi visual tile tetap sinkron.
- [ ] Tidak ada crash ketika pemain melakukan swipe cepat berulang.
- [ ] Gameplay masih berjalan lancar minimal 60 FPS pada board 8x8.
- [ ] Kode animasi dipisahkan dari logic utama board.

---

## 25. Estimasi Task

| Task | Estimasi |
|---|---:|
| Setup state dan animation service | 2–3 jam |
| Implementasi slide swap | 2–4 jam |
| Implementasi invalid return + shake | 2–3 jam |
| Implementasi match pop animation | 2–3 jam |
| Implementasi floating score | 2–3 jam |
| Integrasi dengan board flow | 4–6 jam |
| Testing dan bug fixing | 4–8 jam |

Total estimasi awal: **18–30 jam development**.

---

## 26. Catatan Implementasi Flame

Gunakan import berikut di file animasi:

```dart
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
```

Efek Flame yang akan banyak digunakan:

- `MoveEffect.to`
- `MoveEffect.by`
- `ScaleEffect.to`
- `OpacityEffect.fadeOut`
- `SequenceEffect`
- `EffectController`

---

## 27. Referensi Teknis

- Flame Move Effects: https://docs.flame-engine.org/latest/flame/effects/move_effects.html
- Flame Scale Effects: https://docs.flame-engine.org/latest/flame/effects/scale_effects.html
- Flame Sequence Effect: https://docs.flame-engine.org/latest/flame/effects/sequence_effect.html
- Flame OpacityEffect API: https://pub.dev/documentation/flame/latest/effects/OpacityEffect-class.html

---

## 28. Saran Urutan Implementasi

Urutan implementasi yang disarankan:

1. Kunci input board menggunakan `BoardInteractionState`.
2. Buat `TileAnimationService`.
3. Implementasi animasi swap valid.
4. Implementasi animasi invalid swap return.
5. Implementasi pop animation untuk matched tile.
6. Implementasi floating score.
7. Integrasi gravity dan refill animation.
8. Test cascade/combo.
9. Optimasi feel animasi berdasarkan hasil testing di device Android.

---

## 29. Catatan UX

- Animasi jangan terlalu lama karena match-3 harus terasa cepat.
- Floating score jangan menutupi board terlalu lama.
- Gunakan efek visual yang jelas, tetapi jangan berlebihan.
- Invalid swap harus terasa ringan, bukan seperti error besar.
- Match combo harus terasa lebih rewarding dibanding match biasa.

---

## 30. Future Improvement

Setelah issue ini selesai, fitur animasi bisa dikembangkan lagi menjadi:

- Combo text animation.
- Special tile creation animation.
- Bomb explosion animation.
- Line clear animation.
- Rainbow tile animation.
- Screen shake ringan saat combo besar.
- Haptic feedback untuk match besar.
- SFX berbeda untuk match 3, match 4, match 5, dan combo.
