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
            data: _inputPayload(input));
        return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<PurchaseOrder> update(String id, PoInput input) => guardApi(() async {
        final res = await _dio.put<Map<String, dynamic>>(
            '/api/purchase-orders/$id',
            data: _inputPayload(input));
        return PurchaseOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  /// Payload create/update PO tanpa key bernilai null. Kolom numerik seperti
  /// `dp_amount` bersifat NOT NULL DEFAULT 0 di backend, sehingga mengirim null
  /// (field yang tidak diisi form) memicu error server. Hilangkan key null agar
  /// backend memakai nilai default kolom.
  Map<String, dynamic> _inputPayload(PoInput input) =>
      input.toJson()..removeWhere((_, value) => value == null);

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

  Future<PurchaseOrder> updateTracking(String id, String trackingNumber) =>
      guardApi(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
            '/api/purchase-orders/$id/tracking',
            data: {'tracking_number': trackingNumber});
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

  /// Cetak beberapa PO sekaligus jadi satu PDF (struk / corporate).
  Future<Uint8List> bulkExportPdfBytes(
          List<String> ids, PoBulkPdfFormat format) =>
      guardApi(() async {
        final res = await _dio.post<List<int>>(
          '/api/purchase-orders/bulk-export-pdf',
          data: {'ids': ids, 'format': format.apiValue},
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(res.data!);
      });

  /// Export daftar PO (mengikuti filter & urutan aktif) sebagai file Excel.
  Future<Uint8List> exportExcelBytes({
    PoFilters filters = const PoFilters(),
    String sortBy = 'created_at',
    String sortDir = 'desc',
  }) =>
      guardApi(() async {
        final res = await _dio.get<List<int>>(
          '/api/purchase-orders/export-excel',
          queryParameters: {
            ...filters.toQuery(),
            'sort_by': sortBy,
            'sort_dir': sortDir,
          },
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(res.data!);
      });

  /// Cetak label untuk satu / beberapa PO dalam ukuran tertentu.
  Future<Uint8List> bulkExportLabelsBytes(
          List<String> ids, PoLabelSize size) =>
      guardApi(() async {
        final res = await _dio.post<List<int>>(
          '/api/purchase-orders/bulk-export-labels',
          data: {'ids': ids, 'size': size.apiValue},
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(res.data!);
      });

  /// Cetak label alamat pengiriman untuk satu / beberapa PO (satu label per PO).
  Future<Uint8List> bulkExportAddressLabelsBytes(
          List<String> ids, PoAddressLabelSize size) =>
      guardApi(() async {
        final res = await _dio.post<List<int>>(
          '/api/purchase-orders/bulk-export-address-labels',
          data: {'ids': ids, 'size': size.apiValue},
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

/// Format PDF untuk cetak massal — selaras dengan web (`receipt` / `corporate`).
enum PoBulkPdfFormat {
  receipt,
  corporate;

  String get apiValue => name;

  String get label => switch (this) {
        receipt => 'Struk',
        corporate => 'Corporate (A4)',
      };
}

/// Ukuran label (mm) — daftar sama persis dengan web
/// ([PurchaseOrderListPage.tsx]): 25×15, 30×15, 30×20, 50×30.
enum PoLabelSize {
  s25x15,
  s30x15,
  s30x20,
  s50x30;

  String get apiValue => switch (this) {
        s25x15 => '25x15',
        s30x15 => '30x15',
        s30x20 => '30x20',
        s50x30 => '50x30',
      };

  String get label => switch (this) {
        s25x15 => '25 × 15 mm',
        s30x15 => '30 × 15 mm',
        s30x20 => '30 × 20 mm',
        s50x30 => '50 × 30 mm',
      };
}

/// Ukuran label alamat (mm) — daftar sama persis dengan web
/// (`address-labels`): 100×150, 100×100, 80×50, 60×50, 50×50.
enum PoAddressLabelSize {
  s100x150,
  s100x100,
  s80x50,
  s60x50,
  s50x50;

  String get apiValue => switch (this) {
        s100x150 => '100x150',
        s100x100 => '100x100',
        s80x50 => '80x50',
        s60x50 => '60x50',
        s50x50 => '50x50',
      };

  String get label => switch (this) {
        s100x150 => '100 × 150 mm (A6)',
        s100x100 => '100 × 100 mm',
        s80x50 => '80 × 50 mm',
        s60x50 => '60 × 50 mm',
        s50x50 => '50 × 50 mm',
      };
}
