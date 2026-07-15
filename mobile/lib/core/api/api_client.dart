import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Jembatan event sesi: interceptor memanggil [onUnauthorized] saat server
/// membalas 401 di endpoint terproteksi; AuthNotifier mengisinya saat init.
class SessionEvents {
  void Function()? onUnauthorized;
}

final sessionEventsProvider = Provider<SessionEvents>((ref) => SessionEvents());

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  final tokenStorage = ref.watch(tokenStorageProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Meniru perilaku web (client.ts): 401 di luar endpoint auth
        // → hapus token dan paksa kembali ke halaman login.
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;
        final isAuthEndpoint = path.contains('/api/auth/');
        if (status == 401 && !isAuthEndpoint) {
          await tokenStorage.clear();
          ref.read(sessionEventsProvider).onUnauthorized?.call();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

/// Jalankan request dio dan normalisasi error menjadi [ApiException].
Future<T> guardApi<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}
