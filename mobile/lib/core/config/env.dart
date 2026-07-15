/// Konfigurasi environment via --dart-define.
///
/// Contoh:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
///   flutter build apk --dart-define=API_BASE_URL=https://api.poscheduler.com
class Env {
  Env._();

  /// Base URL backend Laravel (tanpa trailing slash).
  /// Default menunjuk ke `php artisan serve` di host, dilihat dari emulator Android.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Base URL frontend web untuk link katalog publik
  /// (mis. https://poscheduler.vercel.app). Kosong → tombol share katalog
  /// disembunyikan.
  static const String catalogBaseUrl =
      String.fromEnvironment('CATALOG_BASE_URL', defaultValue: '');
}
