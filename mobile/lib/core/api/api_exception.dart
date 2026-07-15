import 'package:dio/dio.dart';

/// Error API yang sudah dinormalisasi agar mudah ditampilkan di UI.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;

  /// Error validasi Laravel per field (response 422 `errors`).
  final Map<String, List<String>> fieldErrors;

  bool get isUnauthorized => statusCode == 401;
  bool get isValidationError => statusCode == 422;

  /// Pesan pertama untuk sebuah field, untuk ditempel di form.
  String? fieldError(String field) => fieldErrors[field]?.firstOrNull;

  factory ApiException.fromDio(DioException e) {
    final response = e.response;

    if (response == null) {
      final message = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'Koneksi ke server melebihi batas waktu. Coba lagi.',
        DioExceptionType.connectionError =>
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        _ => 'Terjadi kesalahan jaringan. Coba lagi.',
      };
      return ApiException(message: message);
    }

    final data = response.data;
    final statusCode = response.statusCode;

    String? serverMessage;
    final fieldErrors = <String, List<String>>{};

    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] as String?;
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List) {
            fieldErrors[entry.key] = value.map((v) => v.toString()).toList();
          }
        }
      }
    }

    final message = serverMessage ??
        switch (statusCode ?? 0) {
          401 => 'Sesi Anda telah berakhir. Silakan login kembali.',
          403 => 'Anda tidak memiliki akses untuk melakukan aksi ini.',
          404 => 'Data tidak ditemukan.',
          422 => 'Data yang dikirim tidak valid.',
          429 => 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.',
          >= 500 => 'Terjadi kesalahan di server. Coba beberapa saat lagi.',
          _ => 'Terjadi kesalahan. Coba lagi.',
        };

    return ApiException(
      message: message,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    );
  }

  @override
  String toString() => message;
}
