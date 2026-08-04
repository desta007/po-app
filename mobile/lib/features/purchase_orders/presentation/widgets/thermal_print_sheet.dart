import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/theme/app_theme.dart';
import '../../services/esc_pos_builder.dart';
import '../../services/thermal_printer_service.dart';

/// Buka sheet cetak thermal: pilih printer, lebar kertas, lalu cetak.
/// [onPrint] melakukan pencetakan sesungguhnya (satu / beberapa struk).
Future<void> showThermalPrintSheet(
  BuildContext context, {
  required int count,
  required Future<void> Function() onPrint,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ThermalPrintSheet(count: count, onPrint: onPrint),
  );
}

class _ThermalPrintSheet extends ConsumerStatefulWidget {
  const _ThermalPrintSheet({required this.count, required this.onPrint});

  final int count;
  final Future<void> Function() onPrint;

  @override
  ConsumerState<_ThermalPrintSheet> createState() => _ThermalPrintSheetState();
}

class _ThermalPrintSheetState extends ConsumerState<_ThermalPrintSheet> {
  bool _printing = false;

  Future<void> _pickPrinter() async {
    final controller = ref.read(thermalPrinterProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    List<BluetoothInfo> printers;
    try {
      printers = await controller.pairedPrinters();
    } on ThermalPrinterException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (!mounted) return;
    if (printers.isEmpty) {
      messenger.showSnackBar(const SnackBar(
          content: Text(
              'Tidak ada printer terpasang. Pasangkan printer di pengaturan Bluetooth HP dulu.')));
      return;
    }
    final chosen = await showModalBottomSheet<BluetoothInfo>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Pilih Printer Thermal',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            for (final p in printers)
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: Text(p.name),
                subtitle: Text(p.macAdress),
                onTap: () => Navigator.of(context).pop(p),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    try {
      await controller.connect(chosen);
      if (mounted) {
        messenger.showSnackBar(
            SnackBar(content: Text('Terhubung ke ${chosen.name}.')));
      }
    } on ThermalPrinterException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _print() async {
    setState(() => _printing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.onPrint();
      if (mounted) {
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(
            content: Text('${widget.count} struk terkirim ke printer.')));
      }
    } on ThermalPrinterException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Gagal mencetak ke printer thermal.')));
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(thermalPrinterProvider);
    final controller = ref.read(thermalPrinterProvider.notifier);
    final connected = state.connectedName;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Cetak Struk Thermal',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            // Printer terhubung
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(connected != null ? Icons.print : Icons.print_disabled,
                      color: connected != null
                          ? AppColors.accent
                          : AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      connected ?? 'Belum ada printer terhubung',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickPrinter,
                    child: Text(connected != null ? 'Ganti' : 'Pilih'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Lebar kertas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SegmentedButton<PaperWidth>(
              segments: const [
                ButtonSegment(value: PaperWidth.mm58, label: Text('58 mm')),
                ButtonSegment(value: PaperWidth.mm80, label: Text('80 mm')),
              ],
              selected: {state.paper},
              onSelectionChanged: (s) => controller.setPaper(s.first),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _printing ? null : _print,
              icon: _printing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : const Icon(Icons.print, size: 20),
              label: Text(_printing
                  ? 'Mencetak…'
                  : 'Cetak ${widget.count} struk'),
            ),
          ],
        ),
      ),
    );
  }
}
