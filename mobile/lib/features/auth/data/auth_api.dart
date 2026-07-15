import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'auth_models.dart';

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(dioProvider)));

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthSession> login({required String email, required String password}) =>
      guardApi(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/api/auth/login',
          data: {'email': email, 'password': password},
        );
        return AuthSession.fromJson(res.data!);
      });

  Future<AuthSession> register(RegisterData data) => guardApi(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/api/auth/register',
          data: data.toJson(),
        );
        return AuthSession.fromJson(res.data!);
      });

  Future<AuthSession> me() => guardApi(() async {
        final res = await _dio.get<Map<String, dynamic>>('/api/auth/me');
        return AuthSession.fromJson(res.data!);
      });

  Future<void> logout() => guardApi(() => _dio.post('/api/auth/logout'));

  Future<void> forgotPassword(String email) => guardApi(
      () => _dio.post('/api/auth/forgot-password', data: {'email': email}));

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) =>
      guardApi(() => _dio.post('/api/auth/reset-password', data: {
            'token': token,
            'email': email,
            'password': password,
            'password_confirmation': passwordConfirmation,
          }));
}
