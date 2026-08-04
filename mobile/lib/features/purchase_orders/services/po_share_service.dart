import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/po_models.dart';
import '../data/purchase_orders_api.dart';

final poShareServiceProvider = Provider<PoShareService>(
    (ref) => PoShareService(ref.watch(purchaseOrdersApiProvider)));

/// Unduh export PO (PDF/gambar/label) ke file sementara lalu buka share sheet
/// native — bisa langsung dikirim ke WhatsApp customer / printer.
class PoShareService {
  PoShareService(this._api);

  final PurchaseOrdersApi _api;

  /// Bagikan export satu PO (struk PDF / corporate PDF / gambar).
  Future<void> share({
    required String poId,
    required String poNumber,
    required PoExportKind kind,
  }) async {
    final bytes = await _api.exportBytes(poId, kind);
    await _shareBytes(bytes,
        fileName: kind.fileName(poNumber),
        subject: 'Purchase Order $poNumber');
  }

  /// Cetak beberapa PO sekaligus jadi satu PDF (struk / corporate).
  Future<void> shareBulkPdf({
    required List<String> ids,
    required PoBulkPdfFormat format,
  }) async {
    final bytes = await _api.bulkExportPdfBytes(ids, format);
    await _shareBytes(bytes,
        fileName: 'PO-${format.apiValue}-${ids.length}.pdf',
        subject: 'Purchase Order (${ids.length})');
  }

  /// Cetak label untuk satu / beberapa PO dalam ukuran tertentu.
  Future<void> shareLabels({
    required List<String> ids,
    required PoLabelSize size,
    String? subject,
  }) async {
    final bytes = await _api.bulkExportLabelsBytes(ids, size);
    await _shareBytes(bytes,
        fileName: 'Label-${size.apiValue}-${ids.length}.pdf',
        subject: subject ?? 'Label PO (${ids.length})');
  }

  /// Export daftar PO (sesuai filter & urutan) ke Excel lalu buka share sheet.
  Future<void> shareExcel({
    PoFilters filters = const PoFilters(),
    String sortBy = 'created_at',
    String sortDir = 'desc',
  }) async {
    final bytes = await _api.exportExcelBytes(
        filters: filters, sortBy: sortBy, sortDir: sortDir);
    final stamp = DateTime.now().toIso8601String().split('T').first;
    await _shareBytes(bytes,
        fileName: 'purchase-orders-$stamp.xlsx',
        subject: 'Daftar Purchase Order');
  }

  Future<void> _shareBytes(
    Uint8List bytes, {
    required String fileName,
    String? subject,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      subject: subject,
    ));
  }
}
