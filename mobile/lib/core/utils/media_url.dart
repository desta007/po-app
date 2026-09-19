import '../config/env.dart';

/// Mengubah path media dari backend menjadi URL absolut yang bisa dimuat
/// oleh [CachedNetworkImage] dkk.
///
/// Laravel mengembalikan sebagian field media sebagai path relatif
/// (mis. `/storage/logos/abc.jpg`). Path seperti itu tidak punya host,
/// sehingga image loader melempar
/// `Invalid argument(s): No host specified in URI ...`.
///
/// Aturan:
/// - `null`, kosong, atau hanya spasi → `null` (pemanggil menampilkan placeholder)
/// - sudah absolut (`http://`, `https://`, `data:`) → dipakai apa adanya
/// - selain itu → digabung dengan [Env.apiBaseUrl]
///
/// Nilai aslinya tidak diubah: resolusi dilakukan saat menampilkan saja,
/// supaya path relatif tetap utuh ketika dikirim balik ke API.
String? resolveMediaUrl(String? raw) {
  final path = raw?.trim();
  if (path == null || path.isEmpty) return null;

  final lower = path.toLowerCase();
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('data:')) {
    return path;
  }

  final base = Env.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
  if (base.isEmpty) return null;

  return path.startsWith('/') ? '$base$path' : '$base/$path';
}
