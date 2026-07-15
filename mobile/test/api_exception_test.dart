import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:po_scheduler_mobile/core/api/api_exception.dart';

DioException _dioError({int? statusCode, dynamic data, DioExceptionType type = DioExceptionType.badResponse}) {
  final options = RequestOptions(path: '/api/test');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response(requestOptions: options, statusCode: statusCode, data: data),
  );
}

void main() {
  test('422 Laravel: pesan + error per field terbaca', () {
    final e = ApiException.fromDio(_dioError(
      statusCode: 422,
      data: {
        'message': 'Data tidak valid.',
        'errors': {
          'email': ['Email sudah terdaftar.'],
          'password': ['Password minimal 8 karakter.', 'Password terlalu umum.'],
        },
      },
    ));

    expect(e.isValidationError, isTrue);
    expect(e.message, 'Data tidak valid.');
    expect(e.fieldError('email'), 'Email sudah terdaftar.');
    expect(e.fieldErrors['password'], hasLength(2));
  });

  test('401 tanpa body message memakai pesan default', () {
    final e = ApiException.fromDio(_dioError(statusCode: 401, data: null));
    expect(e.isUnauthorized, isTrue);
    expect(e.message, contains('login'));
  });

  test('429 throttle memakai pesan default', () {
    final e = ApiException.fromDio(_dioError(statusCode: 429, data: {}));
    expect(e.message, contains('Terlalu banyak'));
  });

  test('connection error tanpa response → pesan jaringan', () {
    final e = ApiException.fromDio(_dioError(type: DioExceptionType.connectionError));
    expect(e.statusCode, isNull);
    expect(e.message, contains('terhubung'));
  });
}
