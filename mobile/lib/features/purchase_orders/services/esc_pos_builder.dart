import 'package:intl/intl.dart';

import '../../settings/data/settings_models.dart';
import '../data/po_models.dart';

/// Lebar kertas thermal — sama seperti web ('58' | '80').
enum PaperWidth {
  mm58,
  mm80;

  String get apiValue => switch (this) {
        mm58 => '58',
        mm80 => '80',
      };

  String get label => switch (this) {
        mm58 => '58 mm',
        mm80 => '80 mm',
      };

  /// Jumlah kolom karakter (font A, 203 dpi): 58mm ≈ 32, 80mm ≈ 48.
  int get columns => switch (this) {
        mm58 => 32,
        mm80 => 48,
      };

  static PaperWidth fromValue(String? v) => v == '58' ? mm58 : mm80;
}

/// Builder perintah ESC/POS — port langsung dari `thermal-printer.ts` (web),
/// supaya struk thermal dari mobile identik dengan yang dari web.
class _EscPos {
  final List<int> _bytes = [];

  _EscPos raw(List<int> b) {
    _bytes.addAll(b);
    return this;
  }

  _EscPos text(String s) {
    for (final ch in _sanitize(s).codeUnits) {
      _bytes.add(ch & 0xff);
    }
    return this;
  }

  _EscPos line([String s = '']) => text(s).raw(const [0x0a]);
  _EscPos init() => raw(const [0x1b, 0x40]);
  _EscPos align(int n) => raw([0x1b, 0x61, n]); // 0 kiri, 1 tengah, 2 kanan
  _EscPos bold(bool on) => raw([0x1b, 0x45, on ? 1 : 0]);
  _EscPos double(bool on) => raw([0x1d, 0x21, on ? 0x11 : 0x00]);
  _EscPos feed(int n) => raw([0x1b, 0x64, n]);
  _EscPos cut() => raw(const [0x1d, 0x56, 0x42, 0x00]);
  List<int> done() => _bytes;
}

/// Buang karakter non-ASCII agar tidak keluar simbol aneh di codepage printer.
String _sanitize(String s) => s
    .replaceAll('×', 'x')
    .replaceAll(RegExp('[–—]'), '-')
    .replaceAll(RegExp(r'[^\x20-\x7E\n]'), '');

final _decimal = NumberFormat.decimalPattern('id_ID');
String _fmt(num n) => _decimal.format(n.round());

final _receiptDate = DateFormat('d MMM yyyy', 'id_ID');
String _fmtDate(String d) {
  final parsed = DateTime.tryParse(d);
  if (parsed == null) return d;
  return _receiptDate.format(parsed);
}

String _divider(int cols) => '-' * cols;

/// Kiri & kanan dalam satu baris selebar [cols], kanan menempel tepi.
String _twoCol(String left, String right, int cols) {
  final gap = cols - left.length - right.length;
  if (gap >= 1) return left + ' ' * gap + right;
  final maxLeft = (cols - right.length - 1).clamp(0, cols);
  return '${left.substring(0, maxLeft.clamp(0, left.length))} $right';
}

/// Pecah teks panjang jadi beberapa baris selebar [cols].
List<String> _wrap(String text, int cols) {
  final words = _sanitize(text).split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  final lines = <String>[];
  var cur = '';
  for (final w in words) {
    var word = w;
    while (word.length > cols) {
      if (cur.isNotEmpty) {
        lines.add(cur);
        cur = '';
      }
      lines.add(word.substring(0, cols));
      word = word.substring(cols);
    }
    if (cur.isEmpty) {
      cur = word;
    } else if ((cur.length + 1 + word.length) <= cols) {
      cur = '$cur $word';
    } else {
      lines.add(cur);
      cur = word;
    }
  }
  if (cur.isNotEmpty) lines.add(cur);
  return lines.isEmpty ? [''] : lines;
}

/// Bangun perintah ESC/POS untuk satu struk PO. [org] opsional — kalau null,
/// header nama toko & info bank dilewati. Selaras dengan `buildReceipt` web.
List<int> buildReceiptBytes(
  PurchaseOrder po,
  Organization? org,
  PaperWidth paper,
) {
  final cols = paper.columns;
  final e = _EscPos().init();

  // Header toko
  e.align(1);
  if (org != null && org.name.isNotEmpty) {
    e.bold(true).double(true).line(org.name).double(false).bold(false);
  }
  if (org?.phone?.isNotEmpty == true) e.line(org!.phone!);
  if (org?.address?.isNotEmpty == true) {
    for (final l in _wrap(org!.address!, cols)) {
      e.line(l);
    }
  }

  // Tampilkan hanya nomor urut PO (mis. "001" dari "PO-20260822-001").
  final poSeq = po.poNumber.split('-').last;
  e.line('INVOICE').line(poSeq.isEmpty ? po.poNumber : poSeq);
  e.align(0).line(_divider(cols));

  // Info pesanan
  final info = <List<String>>[
    ['Tgl Order', _fmtDate(po.orderDate)],
    ['Tgl Kirim', _fmtDate(po.deliveryDate)],
    ['Kepada', po.customer?.name ?? '-'],
  ];
  if (po.customer?.phone?.isNotEmpty == true) {
    info.add(['No HP', po.customer!.phone!]);
  }
  if (po.paymentMethod?.isNotEmpty == true) {
    info.add(['Bayar', po.paymentMethod!]);
  }
  for (final row in info) {
    final prefix = '${row[0]}: ';
    final valLines = _wrap(row[1], cols - prefix.length);
    e.line(prefix + valLines[0]);
    for (var i = 1; i < valLines.length; i++) {
      e.line(' ' * prefix.length + valLines[i]);
    }
  }
  e.line(_divider(cols));

  // Item
  var totalQty = 0.0;
  for (final item in po.items) {
    totalQty += item.quantity;
    for (final l in _wrap(item.productName, cols)) {
      e.line(l);
    }
    if (item.notes?.isNotEmpty == true) {
      for (final l in _wrap(item.notes!, cols)) {
        e.line(l);
      }
    }
    final qtyPrice = '  ${_fmt(item.quantity)} x ${_fmt(item.unitPrice)}';
    e.line(_twoCol(qtyPrice, _fmt(item.subtotal), cols));
  }
  e.line(_divider(cols));

  // Ringkasan
  e.line(_twoCol('Total Qty', _fmt(totalQty), cols));
  e.line(_twoCol('Subtotal', 'Rp ${_fmt(po.subtotal)}', cols));
  if (po.discount > 0) {
    e.line(_twoCol('Diskon', '-${_fmt(po.discount)}', cols));
  }
  if (po.tax > 0) e.line(_twoCol('Pajak', _fmt(po.tax), cols));
  if (po.shippingCost > 0) {
    e.line(_twoCol('Ongkir', _fmt(po.shippingCost), cols));
  }
  e
      .bold(true)
      .line(_twoCol('GRAND TOTAL', 'Rp ${_fmt(po.total)}', cols))
      .bold(false);

  if (po.paidAmount > 0 && po.paidAmount < po.total) {
    e.line(_twoCol('Dibayar', 'Rp ${_fmt(po.paidAmount)}', cols));
    e.line(_twoCol('Sisa', 'Rp ${_fmt(po.total - po.paidAmount)}', cols));
  }
  e.line(_divider(cols));

  // Catatan
  if (po.notes?.isNotEmpty == true) {
    e.align(1).line('Catatan:');
    for (final l in _wrap(po.notes!, cols)) {
      e.line(l);
    }
    e.align(0).line(_divider(cols));
  }

  // Info bank (dari settings organisasi)
  final bank = org?.settings['bank_info'];
  if (bank is Map && bank['bank_name'] != null &&
      bank['bank_name'].toString().isNotEmpty) {
    e.align(1).line('Pembayaran ke rekening:');
    e.bold(true).line(bank['bank_name'].toString()).bold(false);
    final acc = '${bank['account_number'] ?? ''} a.n ${bank['account_name'] ?? ''}';
    e.line(acc.trim());
    e.align(0).line(_divider(cols));
  }

  e.align(1).line('Terima kasih atas pesanan Anda.').align(0);
  e.feed(3).cut();
  return e.done();
}
