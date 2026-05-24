# initial.md — Pondasi Awal Game Match-3 Android dengan Flutter + Flame

> **Nama sementara:** Sweet Match  
> **Genre:** Casual puzzle / match-3  
> **Platform awal:** Android  
> **Engine:** Flutter + Flame  
> **Status dokumen:** Pondasi awal / initial game design & technical plan  
> **Catatan legal:** Game ini terinspirasi dari genre match-3 seperti Candy Crush, tetapi **tidak boleh menyalin nama, logo, karakter, level, UI, musik, efek suara, aset visual, atau branding Candy Crush**. Gunakan identitas, aset, dan mekanik yang dibuat sendiri.

---

## 1. Visi Game

Membuat game puzzle match-3 ringan untuk Android menggunakan Flutter dan Flame, di mana pemain menukar posisi item di papan permainan untuk mencocokkan minimal 3 item yang sama secara horizontal atau vertikal.

Game harus terasa:
- Mudah dimainkan.
- Ringan untuk HP Android kelas menengah.
- Memiliki animasi yang halus.
- Bisa dikembangkan bertahap menjadi level-based puzzle game.
- Memiliki pondasi kode yang rapi agar mudah ditambah fitur seperti booster, special candy, level map, daily reward, iklan, dan in-app purchase.

---

## 2. Target MVP

MVP adalah versi minimum yang sudah bisa dimainkan dari awal sampai selesai level.

### Fitur MVP

- Papan permainan 8x8.
- 5–6 jenis tile/permen.
- Pemain bisa swap dua tile yang bersebelahan.
- Swap hanya valid jika menghasilkan match.
- Jika swap tidak menghasilkan match, tile kembali ke posisi awal.
- Deteksi match horizontal dan vertikal minimal 3 tile.
- Tile yang match akan hilang.
- Tile di atasnya jatuh ke bawah.
- Tile baru muncul dari atas.
- Mendukung cascade/combo otomatis.
- Sistem skor sederhana.
- Sistem langkah/move limit.
- Kondisi menang berdasarkan target skor atau jumlah tile tertentu.
- Kondisi kalah jika langkah habis.
- Overlay UI untuk:
  - Main menu.
  - HUD skor dan move.
  - Pause.
  - Level complete.
  - Game over.

### Bukan Bagian MVP

Fitur berikut jangan dikerjakan dulu agar scope awal tidak terlalu besar:

- Level map seperti Candy Crush.
- Booster kompleks.
- Login user.
- Cloud save.
- Multiplayer.
- Iklan.
- In-app purchase.
- Event harian.
- Leaderboard.
- Ratusan level.
- Physics kompleks.
- Procedural level generator yang terlalu rumit.

---

## 3. Teknologi yang Digunakan

### Core

```yaml
environment:
  sdk: ">=3.5.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  flame: ^1.37.0
  flame_audio: ^2.11.8
  shared_preferences: ^2.5.3
  collection: ^1.19.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

> Versi di atas bisa disesuaikan dengan kondisi terbaru saat development. Untuk langkah awal, jalankan `flutter pub add flame flame_audio shared_preferences collection`.

### Alasan Memakai Flame

Flame cocok untuk game 2D berbasis Flutter karena menyediakan:

- Game loop.
- Component system.
- Sprite rendering.
- Input/gesture handling.
- Effects/animation.
- Audio bridge package.
- Overlay Flutter Widget untuk menu, HUD, pause, dan popup.

---

## 4. Struktur Folder Awal

Gunakan struktur folder seperti ini agar kode mudah dikembangkan:

```text
sweet_match_game/
├── assets/
│   ├── images/
│   │   ├── tiles/
│   │   │   ├── tile_red.png
│   │   │   ├── tile_blue.png
│   │   │   ├── tile_green.png
│   │   │   ├── tile_yellow.png
│   │   │   ├── tile_purple.png
│   │   │   └── tile_orange.png
│   │   ├── backgrounds/
│   │   │   └── bg_level_001.png
│   │   └── ui/
│   │       ├── button_play.png
│   │       ├── panel.png
│   │       └── star.png
│   ├── audio/
│   │   ├── bgm_main.mp3
│   │   ├── sfx_swap.wav
│   │   ├── sfx_match.wav
│   │   ├── sfx_invalid.wav
│   │   └── sfx_win.wav
│   └── levels/
│       ├── level_001.json
│       ├── level_002.json
│       └── level_003.json
│
├── lib/
│   ├── main.dart
│   │
│   ├── app/
│   │   ├── app.dart
│   │   └── routes.dart
│   │
│   ├── game/
│   │   ├── sweet_match_game.dart
│   │   ├── game_state.dart
│   │   ├── game_config.dart
│   │   │
│   │   ├── board/
│   │   │   ├── board_component.dart
│   │   │   ├── board_controller.dart
│   │   │   ├── board_model.dart
│   │   │   ├── board_position.dart
│   │   │   ├── match_result.dart
│   │   │   └── swap_result.dart
│   │   │
│   │   ├── tile/
│   │   │   ├── tile_component.dart
│   │   │   ├── tile_model.dart
│   │   │   ├── tile_type.dart
│   │   │   └── special_tile_type.dart
│   │   │
│   │   ├── level/
│   │   │   ├── level_config.dart
│   │   │   ├── level_loader.dart
│   │   │   └── level_objective.dart
│   │   │
│   │   ├── effects/
│   │   │   ├── tile_pop_effect.dart
│   │   │   ├── tile_fall_effect.dart
│   │   │   └── score_floating_text.dart
│   │   │
│   │   └── input/
│   │       └── swipe_detector.dart
│   │
│   ├── overlays/
│   │   ├── main_menu_overlay.dart
│   │   ├── hud_overlay.dart
│   │   ├── pause_overlay.dart
│   │   ├── level_complete_overlay.dart
│   │   └── game_over_overlay.dart
│   │
│   ├── services/
│   │   ├── audio_service.dart
│   │   ├── save_service.dart
│   │   └── asset_preloader.dart
│   │
│   └── utils/
│       ├── random_util.dart
│       ├── grid_util.dart
│       └── logger.dart
│
├── test/
│   ├── board_controller_test.dart
│   ├── match_detection_test.dart
│   └── level_objective_test.dart
│
├── pubspec.yaml
└── README.md
```

---

## 5. Konsep Gameplay

### Core Loop

1. Pemain melihat papan permainan.
2. Pemain memilih tile dan menukarnya dengan tile sebelahnya.
3. Sistem mengecek apakah swap menghasilkan match.
4. Jika valid:
   - Kurangi jumlah move.
   - Hapus tile yang match.
   - Tambahkan skor.
   - Jalankan animasi tile hilang.
   - Tile di atas jatuh.
   - Tile baru muncul.
   - Cek cascade.
   - Cek objective menang/kalah.
5. Jika tidak valid:
   - Tile dikembalikan.
   - Mainkan efek invalid.
6. Game selesai jika objective tercapai atau move habis.

### Board Awal

Default board:

```text
row: 8
column: 8
tile_size: menyesuaikan lebar layar
tile_types: red, blue, green, yellow, purple, orange
```

Penting:
- Board awal sebaiknya tidak langsung memiliki match otomatis.
- Board awal sebaiknya memiliki minimal satu kemungkinan move valid.
- Jika tidak ada move valid, board diacak ulang.

---

## 6. Aturan Match-3

### Match Valid

Match valid jika terdapat minimal 3 tile dengan tipe sama secara:

- Horizontal.
- Vertikal.

Contoh horizontal:

```text
R R R
```

Contoh vertikal:

```text
B
B
B
```

### Match 4

Jika 4 tile sama cocok dalam satu garis, nanti bisa dibuat special tile:

- Horizontal line clear.
- Vertical line clear.

Untuk MVP, boleh langsung dianggap match biasa dulu.

### Match 5

Jika 5 tile sama cocok, nanti bisa dibuat color bomb.

Untuk MVP, boleh langsung dianggap match biasa dulu.

---

## 7. Data Model Awal

### TileType

```dart
enum TileType {
  red,
  blue,
  green,
  yellow,
  purple,
  orange,
}
```

### SpecialTileType

```dart
enum SpecialTileType {
  none,
  horizontalLine,
  verticalLine,
  bomb,
  colorBomb,
}
```

### TileModel

```dart
class TileModel {
  final String id;
  TileType type;
  SpecialTileType specialType;
  int row;
  int col;
  bool isMatched;
  bool isFalling;
  bool isLocked;

  TileModel({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    this.specialType = SpecialTileType.none,
    this.isMatched = false,
    this.isFalling = false,
    this.isLocked = false,
  });
}
```

### BoardPosition

```dart
class BoardPosition {
  final int row;
  final int col;

  const BoardPosition({
    required this.row,
    required this.col,
  });
}
```

### MatchResult

```dart
class MatchResult {
  final List<TileModel> tiles;
  final bool isHorizontal;
  final bool isVertical;

  MatchResult({
    required this.tiles,
    required this.isHorizontal,
    required this.isVertical,
  });
}
```

---

## 8. Level Config

Simpan konfigurasi level dalam file JSON agar level mudah ditambah tanpa ubah kode.

Contoh `assets/levels/level_001.json`:

```json
{
  "id": 1,
  "name": "Level 1",
  "rows": 8,
  "cols": 8,
  "moves": 20,
  "tileTypes": ["red", "blue", "green", "yellow", "purple"],
  "objective": {
    "type": "score",
    "targetScore": 1000
  },
  "background": "backgrounds/bg_level_001.png"
}
```

Contoh objective lain untuk versi berikutnya:

```json
{
  "objective": {
    "type": "collect",
    "targetTiles": {
      "red": 20,
      "blue": 15
    }
  }
}
```

---

## 9. Game State

Gunakan state yang jelas agar logic tidak bercampur dengan UI.

```dart
enum GameState {
  loading,
  mainMenu,
  playing,
  animating,
  paused,
  levelComplete,
  gameOver,
}
```

### Aturan State

- `loading`: load asset dan level.
- `mainMenu`: tampilkan menu awal.
- `playing`: player boleh input swap.
- `animating`: player tidak boleh input.
- `paused`: game berhenti sementara.
- `levelComplete`: objective tercapai.
- `gameOver`: move habis dan objective belum tercapai.

---

## 10. Arsitektur Teknis

### `SweetMatchGame`

Bertanggung jawab untuk:

- Load asset.
- Load level.
- Menambahkan `BoardComponent`.
- Mengatur game state.
- Mengatur overlay.
- Menghubungkan event dari board ke HUD.
- Pause/resume game.

### `BoardComponent`

Bertanggung jawab untuk:

- Render papan.
- Menempatkan `TileComponent`.
- Menerima input dari tile.
- Mengatur animasi board.
- Memanggil `BoardController` untuk logic.

### `BoardController`

Bertanggung jawab untuk logic murni:

- Generate board.
- Swap tile.
- Validasi adjacent tile.
- Deteksi match.
- Clear matched tile.
- Apply gravity.
- Refill board.
- Cek cascade.
- Cek possible move.

### `TileComponent`

Bertanggung jawab untuk:

- Render sprite tile.
- Menyimpan posisi visual.
- Menangani efek animasi.
- Menangani tap/drag ringan jika diperlukan.

### `HUD Overlay`

Dibuat sebagai Flutter Widget, bukan Flame Component, agar lebih mudah mengatur UI seperti skor, move, pause button, dan progress objective.

---

## 11. Flow Swap Tile

```text
Player input
   ↓
Pilih tile pertama
   ↓
Pilih/geser ke tile kedua
   ↓
Cek apakah adjacent
   ↓
Swap visual
   ↓
Cek match
   ↓
Jika tidak match:
   - swap balik
   - play invalid sound
   - state kembali playing
   ↓
Jika match:
   - kurangi move
   - clear match
   - apply gravity
   - refill
   - cascade
   - update score/objective
   - cek win/lose
```

---

## 12. Algoritma Deteksi Match

### Horizontal

Untuk setiap row:

1. Mulai dari col 0.
2. Hitung tile yang berurutan dengan tipe sama.
3. Jika jumlah >= 3, masukkan ke daftar match.
4. Lanjut ke tile berikutnya.

### Vertical

Untuk setiap col:

1. Mulai dari row 0.
2. Hitung tile yang berurutan dengan tipe sama.
3. Jika jumlah >= 3, masukkan ke daftar match.
4. Lanjut ke tile berikutnya.

### Pseudocode

```text
findMatches(board):
  matches = []

  for each row:
    group = []
    for each col:
      if tile type sama dengan group:
        add tile to group
      else:
        if group length >= 3:
          add group to matches
        start new group

  for each col:
    group = []
    for each row:
      if tile type sama dengan group:
        add tile to group
      else:
        if group length >= 3:
          add group to matches
        start new group

  return matches
```

---

## 13. Gravity dan Refill

### Gravity

Setelah tile match dihapus:

1. Set posisi tile yang match menjadi kosong.
2. Untuk setiap kolom:
   - Ambil tile dari bawah ke atas.
   - Geser tile ke posisi kosong paling bawah.
   - Update row/col model.
   - Jalankan animasi jatuh.

### Refill

Setelah gravity:

1. Hitung jumlah slot kosong di atas.
2. Buat tile baru.
3. Tempatkan tile baru di luar layar bagian atas.
4. Animasikan jatuh ke slot kosong.
5. Setelah semua selesai, cek match lagi untuk cascade.

---

## 14. Sistem Skor

Skor awal sederhana:

```text
match 3 tile  = 30 poin
match 4 tile  = 60 poin
match 5 tile  = 100 poin
combo/cascade = skor x multiplier
```

Contoh multiplier:

```text
cascade pertama = x1
cascade kedua   = x2
cascade ketiga  = x3
```

Untuk MVP, cukup:

```text
score += jumlah_tile_match * 10 * combo_multiplier
```

---

## 15. Objective Level

Jenis objective awal:

### Score Objective

Pemain menang jika skor mencapai target.

```json
{
  "type": "score",
  "targetScore": 1000
}
```

### Collect Objective

Pemain menang jika berhasil mengumpulkan tile tertentu.

```json
{
  "type": "collect",
  "targetTiles": {
    "red": 20,
    "blue": 15
  }
}
```

Untuk MVP, gunakan `score objective` dulu.

---

## 16. UI / Overlay

### Main Menu

Isi:

- Logo game.
- Tombol Play.
- Tombol Settings.
- Tombol Exit jika diperlukan.

### HUD

Isi:

- Score.
- Moves.
- Target.
- Pause button.

### Pause

Isi:

- Resume.
- Restart.
- Back to menu.

### Level Complete

Isi:

- Skor akhir.
- Jumlah bintang.
- Tombol Next.
- Tombol Retry.
- Tombol Home.

### Game Over

Isi:

- Skor akhir.
- Target yang belum tercapai.
- Tombol Retry.
- Tombol Home.

---

## 17. Asset Guideline

### Ukuran Asset

Rekomendasi:

- Tile: 128x128 px PNG transparan.
- Background: 1080x1920 px.
- UI button: 512x160 px.
- Icon: 256x256 px.

### Naming Convention

Gunakan lowercase dan snake_case.

Contoh:

```text
tile_red.png
tile_blue.png
bg_level_001.png
sfx_match.wav
button_play.png
```

### Style Visual

Arah style:

- Cute.
- Colorful.
- Soft rounded.
- High contrast.
- Cocok untuk casual mobile game.

---

## 18. Audio Guideline

Audio awal:

- `sfx_swap.wav`: ketika tile ditukar.
- `sfx_invalid.wav`: ketika swap tidak valid.
- `sfx_match.wav`: ketika match berhasil.
- `sfx_drop.wav`: ketika tile jatuh.
- `sfx_win.wav`: ketika level selesai.
- `bgm_main.mp3`: musik latar.

Pastikan file audio:
- Ringan.
- Tidak terlalu panjang.
- Volume tidak mengganggu.
- Bebas lisensi atau dibuat sendiri.

---

## 19. Responsive Layout

Target utama adalah portrait mode.

### Rule

- Board berada di tengah layar.
- Ukuran tile dihitung dari lebar layar.
- Sisakan padding kiri dan kanan.
- HUD berada di atas board.
- Overlay menggunakan Flutter Widget.

Formula awal:

```text
board_width = screen_width - horizontal_padding
tile_size = board_width / column_count
board_height = tile_size * row_count
```

---

## 20. Android Configuration

Untuk tahap awal:

- Orientasi: portrait.
- Minimum SDK: sesuaikan default Flutter.
- Gunakan app icon custom.
- Gunakan splash screen custom.
- Jangan aktifkan internet permission jika belum perlu.

Nanti jika sudah menggunakan iklan, analytics, atau backend, baru tambahkan permission sesuai kebutuhan.

---

## 21. Testing Plan

### Unit Test

Prioritaskan unit test untuk logic board, bukan rendering.

Test yang wajib:

- Generate board tidak memiliki match awal.
- Swap adjacent valid.
- Swap non-adjacent invalid.
- Match horizontal terdeteksi.
- Match vertical terdeteksi.
- Match 4 terdeteksi.
- Gravity bekerja setelah clear.
- Refill mengisi slot kosong.
- Move berkurang saat swap valid.
- Move tidak berkurang saat swap invalid.
- Objective score tercapai.
- Game over saat move habis.

### Manual Test

Checklist manual:

- Game bisa dibuka di Android emulator.
- Board tampil penuh.
- Tile bisa disentuh.
- Swap terasa responsif.
- Animasi tidak patah-patah.
- Tidak ada input saat animasi berjalan.
- Menang dan kalah tampil dengan benar.
- Restart level bekerja.
- Pause dan resume bekerja.

---

## 22. Performance Guideline

Agar game ringan:

- Preload semua asset sebelum level mulai.
- Gunakan sprite sheet jika jumlah asset makin banyak.
- Jangan membuat object berlebihan setiap frame.
- Hindari logic berat di method `update`.
- Pisahkan logic board dari rendering.
- Gunakan pooling untuk efek jika nanti banyak particle.
- Pastikan animasi tidak tumpang tindih.
- Gunakan state `animating` untuk lock input saat board sedang bergerak.

---

## 23. Roadmap Development

### Phase 0 — Setup Project

- Buat project Flutter.
- Tambahkan Flame.
- Setup folder.
- Setup assets.
- Setup main game class.
- Setup `GameWidget`.
- Setup portrait mode.

Output:
- App Android bisa jalan.
- Layar game kosong tampil.

### Phase 1 — Render Board

- Buat board 8x8.
- Generate tile random.
- Render tile sebagai sprite/component.
- Hitung posisi tile berdasarkan row/col.
- Pastikan responsive.

Output:
- Board tampil dengan tile random.

### Phase 2 — Input dan Swap

- Tap tile.
- Pilih tile pertama.
- Tap/drag tile kedua.
- Validasi adjacent.
- Animasi swap.
- Swap invalid kembali.

Output:
- Tile bisa ditukar.

### Phase 3 — Match Detection

- Deteksi match horizontal.
- Deteksi match vertical.
- Hapus tile match.
- Update skor.

Output:
- Match bisa hilang dan skor bertambah.

### Phase 4 — Gravity dan Refill

- Tile jatuh ke bawah.
- Tile baru muncul dari atas.
- Cascade otomatis.

Output:
- Board selalu terisi lagi setelah match.

### Phase 5 — Objective dan Level

- Load level dari JSON.
- Tambahkan move limit.
- Tambahkan target skor.
- Tambahkan win/lose condition.

Output:
- Level bisa dimenangkan atau kalah.

### Phase 6 — UI Polish

- Main menu.
- HUD.
- Pause.
- Level complete.
- Game over.
- Sound effect.
- Animasi lebih halus.

Output:
- Game MVP terasa playable.

### Phase 7 — Fitur Lanjutan

- Special tile.
- Booster.
- Level map.
- Save progress.
- Daily reward.
- Ads.
- In-app purchase.
- Analytics.
- Cloud sync.

---

## 24. Command Awal

### Buat Project

```bash
flutter create sweet_match_game
cd sweet_match_game
```

### Tambah Dependency

```bash
flutter pub add flame flame_audio shared_preferences collection
```

### Jalankan

```bash
flutter run
```

### Build APK Debug

```bash
flutter build apk --debug
```

### Build APK Release

```bash
flutter build apk --release
```

---

## 25. Setup `pubspec.yaml` Assets

Tambahkan:

```yaml
flutter:
  assets:
    - assets/images/tiles/
    - assets/images/backgrounds/
    - assets/images/ui/
    - assets/audio/
    - assets/levels/
```

---

## 26. Contoh Main Entry

`lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const SweetMatchApp());
}
```

`lib/app/app.dart`

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/sweet_match_game.dart';
import '../overlays/game_over_overlay.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/level_complete_overlay.dart';
import '../overlays/main_menu_overlay.dart';
import '../overlays/pause_overlay.dart';

class SweetMatchApp extends StatelessWidget {
  const SweetMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = SweetMatchGame();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sweet Match',
      home: Scaffold(
        body: GameWidget<SweetMatchGame>(
          game: game,
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenuOverlay(game: game),
            'HUD': (context, game) => HudOverlay(game: game),
            'Pause': (context, game) => PauseOverlay(game: game),
            'LevelComplete': (context, game) => LevelCompleteOverlay(game: game),
            'GameOver': (context, game) => GameOverOverlay(game: game),
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    );
  }
}
```

---

## 27. Prinsip Coding

- Logic board harus bisa dites tanpa Flame.
- Flame Component hanya untuk visual/rendering/input.
- Hindari logic game penting langsung di Widget.
- Gunakan nama class yang jelas.
- Jangan campur audio, board logic, dan UI dalam satu class.
- Gunakan enum untuk state dan tile type.
- Hindari magic number; taruh di `game_config.dart`.
- Buat function kecil dan mudah dites.

---

## 28. Branch Git yang Disarankan

```text
main
develop
feature/project-setup
feature/board-render
feature/tile-swap
feature/match-detection
feature/gravity-refill
feature/level-system
feature/ui-overlay
feature/audio
feature/polish
```

---

## 29. Definition of Done MVP

MVP dianggap selesai jika:

- Game bisa dibuka di Android.
- Board 8x8 tampil.
- Tile bisa diswap.
- Match bisa dideteksi.
- Tile match hilang.
- Gravity dan refill berjalan.
- Cascade berjalan.
- Skor bertambah.
- Move berkurang.
- Level bisa menang.
- Level bisa kalah.
- Pause, retry, dan home berjalan.
- Tidak ada crash pada flow normal.
- Game masih playable di HP Android kelas menengah.

---

## 30. Prioritas Pengerjaan

Urutan paling aman:

1. Setup project.
2. Buat struktur folder.
3. Buat model tile dan board.
4. Buat board generator.
5. Buat unit test board.
6. Render tile dengan Flame.
7. Tambahkan input tap/swap.
8. Tambahkan match detection.
9. Tambahkan clear, gravity, refill.
10. Tambahkan HUD.
11. Tambahkan level JSON.
12. Tambahkan win/lose.
13. Tambahkan audio.
14. Polish animasi.
15. Build APK.

---

## 31. Catatan Risiko

### Risiko 1 — Logic Board Terlalu Bercampur dengan Flame

Solusi:
- Buat `BoardController` sebagai pure Dart class.
- Unit test logic tanpa menjalankan game.

### Risiko 2 — Input Masuk Saat Animasi

Solusi:
- Gunakan state `animating`.
- Semua input swap ditolak ketika board sedang animasi.

### Risiko 3 — Board Tidak Punya Move Valid

Solusi:
- Setelah generate/refill, cek possible move.
- Jika tidak ada move valid, shuffle board.

### Risiko 4 — Asset Terlalu Berat

Solusi:
- Kompres gambar.
- Gunakan ukuran tile secukupnya.
- Hindari animasi berlebihan di MVP.

### Risiko 5 — Scope Terlalu Besar

Solusi:
- Fokus ke MVP dulu.
- Special tile, booster, level map, dan monetisasi dikerjakan setelah core gameplay stabil.

---

## 32. Checklist Awal

- [ ] Buat project Flutter.
- [ ] Tambahkan Flame.
- [ ] Setup folder `assets`.
- [ ] Setup folder `lib/game`.
- [ ] Setup `SweetMatchGame`.
- [ ] Setup `GameWidget`.
- [ ] Setup overlay map.
- [ ] Buat `TileType`.
- [ ] Buat `TileModel`.
- [ ] Buat `BoardModel`.
- [ ] Buat `BoardController`.
- [ ] Generate board random.
- [ ] Render board 8x8.
- [ ] Implement tap/swap.
- [ ] Implement match detection.
- [ ] Implement clear tile.
- [ ] Implement gravity.
- [ ] Implement refill.
- [ ] Implement score.
- [ ] Implement moves.
- [ ] Implement level complete.
- [ ] Implement game over.
- [ ] Build APK debug.

---

## 33. Nama Alternatif Game

Beberapa ide nama agar tidak mirip dengan Candy Crush:

- Sweet Match
- Jelly Pop
- Sugar Quest
- Candy Garden
- Cookie Blast
- Fruit Swap
- Gemmy Land
- Lollipop Journey
- Bubble Sweets
- Matchy Treats

---

## 34. Kesimpulan Pondasi

Pondasi awal game ini harus fokus pada core mechanic match-3 terlebih dahulu:

```text
swap → validate → match → clear → gravity → refill → cascade → objective
```

Jika flow ini sudah stabil, fitur lain seperti special tile, booster, map level, daily reward, iklan, dan in-app purchase akan lebih mudah ditambahkan tanpa merombak arsitektur utama.
