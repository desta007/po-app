import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final _dateFormat = DateFormat('d MMM yyyy', 'id_ID');
final _dateTimeFormat = DateFormat('d MMM yyyy HH:mm', 'id_ID');

String formatRupiah(num value) => _rupiah.format(value);

String formatDate(DateTime date) => _dateFormat.format(date);

String formatDateString(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final parsed = DateTime.tryParse(iso);
  return parsed == null ? '-' : _dateFormat.format(parsed.toLocal());
}

String formatDateTimeString(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final parsed = DateTime.tryParse(iso);
  return parsed == null ? '-' : _dateTimeFormat.format(parsed.toLocal());
}
