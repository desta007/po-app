import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../settings/data/settings_models.dart';
import '../data/po_models.dart';
import 'esc_pos_builder.dart';

/// Error cetak thermal yang ramah-tampil ke pengguna.
class ThermalPrinterException implements Exception {
  ThermalPrinterException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// State printer thermal: lebar kertas + nama printer terhubung.
class ThermalPrinterState {
  const ThermalPrinterState({
    this.paper = PaperWidth.mm80,
    this.connectedName,
    this.busy = false,
  });

  final PaperWidth paper;
  final String? connectedName;
  final bool busy;

  ThermalPrinterState copyWith({
    PaperWidth? paper,
    String? Function()? connectedName,
    bool? busy,
  }) =>
      ThermalPrinterState(
        paper: paper ?? this.paper,
        connectedName:
            connectedName != null ? connectedName() : this.connectedName,
        busy: busy ?? this.busy,
      );
}

const _kPaperKey = 'thermal_paper_width';
const _kMacKey = 'thermal_printer_mac';
const _kNameKey = 'thermal_printer_name';

final thermalPrinterProvider =
    NotifierProvider<ThermalPrinterController, ThermalPrinterState>(
        ThermalPrinterController.new);

class ThermalPrinterController extends Notifier<ThermalPrinterState> {
  String? _savedMac;

  @override
  ThermalPrinterState build() {
    Future.microtask(_loadPrefs);
    return const ThermalPrinterState();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _savedMac = prefs.getString(_kMacKey);
    state = state.copyWith(
      paper: PaperWidth.fromValue(prefs.getString(_kPaperKey)),
      connectedName: () => prefs.getString(_kNameKey),
    );
  }

  Future<void> setPaper(PaperWidth paper) async {
    state = state.copyWith(paper: paper);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaperKey, paper.apiValue);
  }

  /// Daftar printer yang sudah dipasangkan (bonded) di pengaturan Bluetooth HP.
  Future<List<BluetoothInfo>> pairedPrinters() async {
    if (!await PrintBluetoothThermal.isPermissionBluetoothGranted) {
      throw ThermalPrinterException(
          'Izin Bluetooth belum diberikan. Aktifkan izin Bluetooth untuk aplikasi ini.');
    }
    if (!await PrintBluetoothThermal.bluetoothEnabled) {
      throw ThermalPrinterException(
          'Bluetooth belum aktif. Nyalakan Bluetooth lalu coba lagi.');
    }
    return PrintBluetoothThermal.pairedBluetooths;
  }

  /// Sambungkan ke printer terpilih & simpan untuk sambung ulang otomatis.
  Future<void> connect(BluetoothInfo printer) async {
    final ok = await PrintBluetoothThermal.connect(
        macPrinterAddress: printer.macAdress);
    if (!ok) {
      throw ThermalPrinterException(
          'Gagal terhubung ke ${printer.name}. Pastikan printer menyala & dalam jangkauan.');
    }
    _savedMac = printer.macAdress;
    state = state.copyWith(connectedName: () => printer.name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMacKey, printer.macAdress);
    await prefs.setString(_kNameKey, printer.name);
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    state = state.copyWith(connectedName: () => null);
  }

  /// Pastikan ada printer siap; sambung ulang ke printer terakhir bila perlu.
  Future<void> _ensureConnected() async {
    if (await PrintBluetoothThermal.connectionStatus) return;
    final mac = _savedMac;
    if (mac != null && mac.isNotEmpty) {
      final ok = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      if (ok) return;
    }
    throw ThermalPrinterException(
        'Belum ada printer terhubung. Pilih printer thermal terlebih dahulu.');
  }

  /// Cetak satu struk PO ke printer thermal.
  Future<void> printReceipt(PurchaseOrder po, Organization? org) async {
    await _ensureConnected();
    final bytes = buildReceiptBytes(po, org, state.paper);
    final ok = await PrintBluetoothThermal.writeBytes(bytes);
    if (!ok) {
      throw ThermalPrinterException(
          'Gagal mengirim data ke printer. Coba sambungkan ulang printer.');
    }
  }

  /// Cetak beberapa struk PO sekaligus (koneksi dipastikan sekali di awal).
  Future<void> printReceipts(
      List<PurchaseOrder> orders, Organization? org) async {
    await _ensureConnected();
    for (final po in orders) {
      final bytes = buildReceiptBytes(po, org, state.paper);
      final ok = await PrintBluetoothThermal.writeBytes(bytes);
      if (!ok) {
        throw ThermalPrinterException(
            'Gagal mencetak struk ${po.poNumber}. Koneksi printer terputus.');
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
}
