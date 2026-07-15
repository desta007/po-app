# PO Scheduler — Mobile App (Flutter)

Client mobile (Android & iOS) untuk backend Laravel di `../backend`.
Lihat rencana lengkap di [implementation_plan_mobile_flutter.md](../implementation_plan_mobile_flutter.md).

## Menjalankan (development)

Pastikan backend jalan dulu:

```bash
cd ../backend
php artisan serve   # default http://localhost:8000
```

Lalu jalankan app:

```bash
# Emulator Android (10.0.2.2 = localhost host) — default, tanpa argumen tambahan
flutter run

# Device fisik (HP dan PC satu WiFi, ganti dengan IP PC Anda)
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000

# Production
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

> Catatan: HTTP non-TLS hanya diizinkan di build **debug**
> (`android/app/src/debug/AndroidManifest.xml`). Build release wajib HTTPS.

## Struktur

```
lib/
├── core/        # api client (dio + Bearer token), router, theme, storage, utils
├── features/    # per fitur: data/ (api+model), providers/, presentation/
└── shared/      # widget lintas fitur
```

- State management: Riverpod · Routing: go_router · Model: freezed + json_serializable
- Token Sanctum disimpan di Keychain/Keystore (`flutter_secure_storage`)
- Response 401 di endpoint terproteksi → token dihapus, auto redirect ke login

## Codegen model

Setelah mengubah file model (`*_models.dart`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Test & lint

```bash
flutter analyze
flutter test
```

## Status fase

- ✅ Fase 1 — fondasi, auth (login/register/lupa & reset password), shell navigasi
- ✅ Fase 2 — purchase order (list/detail/form, status, pembayaran, share PDF & gambar), pelanggan, produk
- ✅ Fase 3 — dashboard (ringkasan + chart), kalender pengiriman + reschedule, laporan omzet & laba, notifikasi (export Excel menunggu backend — masih 501)
- ✅ Fase 4 — settings (profil + ganti password, organisasi + logo, metode pembayaran, preferensi notifikasi), anggota tim (owner/admin), langganan + kuota (push notification ditunda; editor toko online tetap di web)
- ⬜ Fase 5 — polish & release
