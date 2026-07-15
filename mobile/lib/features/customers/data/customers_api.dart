import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/pagination.dart';
import 'customer_models.dart';

final customersApiProvider =
    Provider<CustomersApi>((ref) => CustomersApi(ref.watch(dioProvider)));

class CustomersApi {
  CustomersApi(this._dio);

  final Dio _dio;

  Future<Paginated<Customer>> list({
    String? search,
    int page = 1,
    int perPage = 20,
  }) =>
      guardApi(() async {
        final res = await _dio.get<Map<String, dynamic>>('/api/customers',
            queryParameters: {
              if (search != null && search.isNotEmpty) 'search': search,
              'page': page,
              'per_page': perPage,
            });
        return Paginated.fromJson(res.data!, Customer.fromJson);
      });

  Future<Customer> show(String id) => guardApi(() async {
        final res = await _dio.get<Map<String, dynamic>>('/api/customers/$id');
        return Customer.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<Customer> create(CustomerInput input) => guardApi(() async {
        final res = await _dio.post<Map<String, dynamic>>('/api/customers',
            data: input.toJson());
        return Customer.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<Customer> update(String id, CustomerInput input) =>
      guardApi(() async {
        final res = await _dio.put<Map<String, dynamic>>('/api/customers/$id',
            data: input.toJson());
        return Customer.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<void> delete(String id) =>
      guardApi(() => _dio.delete('/api/customers/$id'));
}
