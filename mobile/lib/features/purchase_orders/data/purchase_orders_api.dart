import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/pagination.dart';
import 'po_models.dart';

final purchaseOrdersApiProvider = Provider<PurchaseOrdersApi>(
    (ref) => PurchaseOrdersApi(ref.watch(dioProvider)));

class PurchaseOrdersApi {
  PurchaseOrdersApi(this._dio);

  final Dio _dio;

  Future<Paginated<PurchaseOrder>> list({
    PoFilters filters = const PoFilters(),
    int page = 1,
    int perPage = 20,
    String sortBy = 'created_at',
    String sortDir = 'desc',
  }) =>
      guardApi(() async {
        final res = await _dio
            .get<Map<String, dynamic>>('/api/purchase-orders', queryParameters: {
          ...filters.toQuery(),
          'page': page,
          'per_page': perPage,
          'sort_by': sortBy,
          'sort_dir': sortDir,
        });
        return Paginated.fromJson(res.data!, PurchaseOrder.fromJson);
      });

  Future<PurchaseOrder> show(String id) => guardApi(() async {
        final res =
            await _dio.get<Map<String, dynamic>>('/api/purchase-orders/$id');
        return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<PurchaseOrder> create(PoInput input) => guardApi(() async {
        final res = await _dio.post<Map<String, dynamic>>(
            '/api/purchase-orders',
            data: input.toJson());
        return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<PurchaseOrder> update(String id, PoInput input) => guardApi(() async {
        final res = await _dio.put<Map<String, dynamic>>(
            '/api/purchase-orders/$id',
            data: input.toJson());
        return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<PurchaseOrder> updateStatus(String id, PoStatus status,
          {String? reason}) =>
      guardApi(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
            '/api/purchase-orders/$id/status',
            data: {'status': status.apiValue, 'reason': ?reason});
        return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<PurchaseOrder> updatePayment(
    String id, {
    required PaymentStatus paymentStatus,
    required double paidAmount,
    String? paymentMethod,
  }) =>
      guardApi(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
            '/api/purchase-orders/$id/payment',
            data: {
              'payment_status': paymentStatus.name,
              'paid_amount': paidAmount,
              'payment_method': paymentMethod,
            });
        return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<PurchaseOrder> cancel(String id, {String? reason}) =>
      guardApi(() async {
        final res = await _dio.post<Map<String, dynamic>>(
            '/api/purchase-orders/$id/cancel',
            data: {'reason': ?reason});
        return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<PurchaseOrder> duplicate(String id) => guardApi(() async {
        final res = await _dio
            .post<Map<String, dynamic>>('/api/purchase-orders/$id/duplicate');
        return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  /// Unduh PDF struk / corporate / gambar sebagai bytes untuk dishare.
  Future<Uint8List> exportBytes(String id, PoExportKind kind) =>
      guardApi(() async {
        final res = await _dio.get<List<int>>(
          '/api/purchase-orders/$id/${kind.path}',
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(res.data!);
      });
}

enum PoExportKind {
  receiptPdf,
  corporatePdf,
  image;

  String get path => switch (this) {
        receiptPdf => 'export-pdf',
        corporatePdf => 'export-corporate-pdf',
        image => 'export-image',
      };

  String get label => switch (this) {
        receiptPdf => 'PDF Struk',
        corporatePdf => 'PDF Corporate',
        image => 'Gambar (JPG/PNG)',
      };

  String fileName(String poNumber) => switch (this) {
        receiptPdf => 'PO-$poNumber.pdf',
        corporatePdf => 'PO-$poNumber-corporate.pdf',
        image => 'PO-$poNumber.png',
      };
}
