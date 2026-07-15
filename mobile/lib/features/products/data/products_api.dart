import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/pagination.dart';
import 'product_models.dart';

final productsApiProvider =
    Provider<ProductsApi>((ref) => ProductsApi(ref.watch(dioProvider)));

class ProductsApi {
  ProductsApi(this._dio);

  final Dio _dio;

  Future<Paginated<Product>> list({
    String? search,
    bool? isActive,
    int page = 1,
    int perPage = 20,
  }) =>
      guardApi(() async {
        final res = await _dio.get<Map<String, dynamic>>('/api/products',
            queryParameters: {
              if (search != null && search.isNotEmpty) 'search': search,
              'is_active': ?isActive,
              'page': page,
              'per_page': perPage,
            });
        return Paginated.fromJson(res.data!, Product.fromJson);
      });

  Future<Product> show(String id) => guardApi(() async {
        final res = await _dio.get<Map<String, dynamic>>('/api/products/$id');
        return Product.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<Product> create(ProductInput input) => guardApi(() async {
        final res = await _dio.post<Map<String, dynamic>>('/api/products',
            data: input.toJson());
        return Product.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<Product> update(String id, ProductInput input) => guardApi(() async {
        final res = await _dio.put<Map<String, dynamic>>('/api/products/$id',
            data: input.toJson());
        return Product.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<void> delete(String id) =>
      guardApi(() => _dio.delete('/api/products/$id'));

  Future<void> uploadImage(String id, String filePath) => guardApi(() async {
        final form = FormData.fromMap({
          'image': await MultipartFile.fromFile(filePath),
        });
        await _dio.post('/api/products/$id/image', data: form);
      });

  Future<void> deleteImage(String id, {String? imageUrl}) => guardApi(
        () => _dio.delete('/api/products/$id/image',
            data: imageUrl != null ? {'image_url': imageUrl} : null),
      );
}
