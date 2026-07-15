import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/purchase_orders_api.dart';

final poShareServiceProvider = Provider<PoShareService>(
    (ref) => PoShareService(ref.watch(purchaseOrdersApiProvider)));

/// Unduh export PO (PDF/gambar) ke file sementara lalu buka share sheet
/// native — bisa langsung dikirim ke WhatsApp customer.
class PoShareService {
  PoShareService(this._api);

  final PurchaseOrdersApi _api;

  Future<void> share({
    required String poId,
    required String poNumber,
    required PoExportKind kind,
  }) async {
    final bytes = await _api.exportBytes(poId, kind);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${kind.fileName(poNumber)}');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      subject: 'Purchase Order $poNumber',
    ));
  }
}
