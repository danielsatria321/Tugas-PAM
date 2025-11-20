# Quiz App

Aplikasi mobile quiz interaktif berbasis Flutter untuk belajar pengetahuan umum tentang negara-negara di dunia.

## Fitur Utama

### Autentikasi

- Register dan login dengan enkripsi password SHA-256
- Session management untuk persistent login
- Database SQLite lokal untuk menyimpan data user

### Quiz Interaktif

- Tebak Bendera
- Tebak Lambang Negara
- Tebak Ibukota
- Tebak Benua
- Tebak Bahasa
- Tebak Mata Uang

### Sistem Gamifikasi

- XP (Experience Points) yang bertambah setiap menyelesaikan quiz
- Score history untuk tracking progress
- Leaderboard untuk melihat ranking user

### Membership System

- Free tier: akses terbatas
- Premium tier: akses penuh semua fitur
- Upgrade membership melalui halaman membership

### Notifikasi

- Learning reminder otomatis setiap 60 detik
- Action buttons: Mulai Belajar dan Tunda
- Notifikasi persisten dengan awesome_notifications

### Visualisasi Data

- Chart progress menggunakan fl_chart
- Statistik skor per quiz
- Timeline progress belajar

## Teknologi

### Framework & Language

- Flutter 3.9.2
- Dart

### Database

- SQLite (sqflite)
- Shared Preferences untuk session

### Security

- SHA-256 password hashing (crypto package)

### UI/UX

- Simple Animations untuk transisi smooth
- Carousel Slider untuk konten dinamis
- Material Design 3

### API & Services

- HTTP client untuk fetch data negara
- Path Provider untuk file storage
- Permission Handler untuk izin notifikasi

## Struktur Database

```sql
users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE,
  password_hash TEXT,
  name TEXT,
  xp INTEGER DEFAULT 0,
  subscription_status TEXT DEFAULT 'free',
  score_history TEXT DEFAULT '[]'
)
```

## Dependencies

```yaml
dependencies:
  flutter: sdk
  simple_animations: ^5.2.0
  http: ^1.5.0
  carousel_slider: ^5.1.1
  fl_chart: ^0.65.0
  sqflite: ^2.4.0
  path: ^1.9.0
  crypto: ^3.0.3
  shared_preferences: ^2.5.3
  path_provider: ^2.1.5
  synchronize: ^1.1.1
  permission_handler: ^12.0.1
  awesome_notifications: ^0.10.1
```

## Platform Support

- Android
- iOS
- Web (limited)
- Windows
- macOS
- Linux

## Keamanan

Password tidak disimpan dalam bentuk plain text. Menggunakan SHA-256 hashing untuk enkripsi password sebelum disimpan ke database.

## Penulis

Daniel Satria
