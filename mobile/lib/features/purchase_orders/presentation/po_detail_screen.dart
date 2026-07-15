import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_states.dart';
import '../data/po_models.dart';
import '../data/purchase_orders_api.dart';
import '../providers/po_providers.dart';
import '../services/po_share_service.dart';
import 'widgets/po_badges.dart';

class PoDetailScreen extends ConsumerWidget {
  const PoDetailScreen({super.key, required this.poId});

  final String poId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(poDetailProvider(poId));

    return Scaffold(
      appBar: AppBar(
        title: Text(async.value?.poNumber ?? 'Detail PO'),
        actions: [
          if (async.hasValue)
            PopupMenuButton<String>(
              onSelected: (action) =>
                  _onMenuAction(context, ref, action, async.value!),
              itemBuilder: (context) => [
                if (!async.value!.status.isFinal)
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit PO')),
                const PopupMenuItem(
                    value: 'duplicate', child: Text('Duplikat PO')),
                if (!async.value!.status.isFinal)
                  const PopupMenuItem(
                      value: 'cancel', child: Text('Batalkan PO')),
              ],
            ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(
          message: e is ApiException ? e.message : 'Terjadi kesalahan.',
          onRetry: () => ref.invalidate(poDetailProvider(poId)),
        ),
        data: (po) => _PoDetailBody(po: po, poId: poId),
      ),
      bottomNavigationBar: async.hasValue
          ? _ActionBar(po: async.value!, poId: poId)
          : null,
    );
  }

  Future<void> _onMenuAction(BuildContext context, WidgetRef ref,
      String action, PurchaseOrder po) async {
    switch (action) {
      case 'edit':
        context.push('/po/$poId/edit', extra: po);
      case 'duplicate':
        try {
          final newPo =
              await ref.read(poDetailProvider(poId).notifier).duplicate();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('PO diduplikat: ${newPo.poNumber}')));
            context.push('/po/${newPo.id}');
          }
        } on ApiException catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.message)));
          }
        }
      case 'cancel':
        await _confirmCancel(context, ref);
    }
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan PO'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PO yang dibatalkan tidak dapat dikembalikan.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration:
                  const InputDecoration(labelText: 'Alasan (opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Kembali')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Batalkan PO'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final reason = reasonController.text.trim();
      await ref
          .read(poDetailProvider(poId).notifier)
          .cancel(reason: reason.isEmpty ? null : reason);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('PO dibatalkan.')));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _PoDetailBody extends StatelessWidget {
  const _PoDetailBody({required this.po, required this.poId});

  final PurchaseOrder po;
  final String poId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header: status + tanggal
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PoStatusBadge(status: po.status),
                    const SizedBox(width: 8),
                    PaymentStatusBadge(status: po.paymentStatus),
                    const Spacer(),
                    Text(formatRupiah(po.total),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 20),
                _KeyValue(label: 'Pelanggan', value: po.customer?.name ?? '-'),
                _KeyValue(
                    label: 'Tgl Order',
                    value: formatDateString(po.orderDate)),
                _KeyValue(
                    label: 'Tgl Kirim',
                    value: formatDateString(po.deliveryDate)),
                if (po.customer?.phone?.isNotEmpty == true)
                  _KeyValue(label: 'Telepon', value: po.customer!.phone!),
                if (po.notes?.isNotEmpty == true)
                  _KeyValue(label: 'Catatan', value: po.notes!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Items
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Item Pesanan',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                for (final item in po.items) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName),
                            Text(
                              '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} × ${formatRupiah(item.unitPrice)}'
                              '${item.notes?.isNotEmpty == true ? '\n${item.notes}' : ''}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(formatRupiah(item.subtotal)),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                const Divider(),
                _SummaryRow(label: 'Subtotal', value: po.subtotal),
                if (po.discount > 0)
                  _SummaryRow(label: 'Diskon', value: -po.discount),
                if (po.tax > 0) _SummaryRow(label: 'Pajak', value: po.tax),
                if (po.shippingCost > 0)
                  _SummaryRow(label: 'Ongkir', value: po.shippingCost),
                _SummaryRow(label: 'Total', value: po.total, bold: true),
                const Divider(),
                _SummaryRow(label: 'Dibayar', value: po.paidAmount),
                _SummaryRow(
                  label: 'Sisa',
                  value: (po.total - po.paidAmount).clamp(0, double.infinity),
                  bold: true,
                ),
                if (po.paymentMethod?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Metode: ${po.paymentMethod}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Riwayat status
        if (po.statusHistory.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Riwayat Status',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final h in po.statusHistory)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.circle,
                              size: 8, color: h.toStatus.color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${h.fromStatus != null ? '${h.fromStatus!.label} → ' : ''}${h.toStatus.label}'
                              '${h.reason?.isNotEmpty == true ? ' — ${h.reason}' : ''}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            formatDateTimeString(h.changedAt),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}

/// Bar aksi bawah: ubah status, pembayaran, share.
class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.po, required this.poId});

  final PurchaseOrder po;
  final String poId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            if (!po.status.isFinal) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showStatusSheet(context, ref),
                  icon: const Icon(Icons.swap_horiz, size: 20),
                  label: const Text('Status'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (po.paymentStatus != PaymentStatus.paid &&
                po.status != PoStatus.cancelled) ...[
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent),
                  onPressed: () => _showPaymentSheet(context, ref),
                  icon: const Icon(Icons.payments_outlined, size: 20),
                  label: const Text('Bayar'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showShareSheet(context, ref),
                icon: const Icon(Icons.share_outlined, size: 20),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStatusSheet(BuildContext context, WidgetRef ref) async {
    final transitions =
        po.status.allowedTransitions.where((s) => s != PoStatus.cancelled);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ubah status dari "${po.status.label}" ke:',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final target in transitions)
              ListTile(
                leading: Icon(Icons.arrow_forward, color: target.color),
                title: Text(target.label),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await ref
                        .read(poDetailProvider(poId).notifier)
                        .updateStatus(target);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Status diubah ke ${target.label}.')));
                    }
                  } on ApiException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message)));
                    }
                  }
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showPaymentSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _PaymentSheet(po: po, poId: poId),
    );
  }

  Future<void> _showShareSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bagikan PO sebagai:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final kind in PoExportKind.values)
              ListTile(
                leading: Icon(kind == PoExportKind.image
                    ? Icons.image_outlined
                    : Icons.picture_as_pdf_outlined),
                title: Text(kind.label),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                      const SnackBar(content: Text('Menyiapkan file…')));
                  try {
                    await ref.read(poShareServiceProvider).share(
                        poId: poId, poNumber: po.poNumber, kind: kind);
                    messenger.hideCurrentSnackBar();
                  } on ApiException catch (e) {
                    messenger.hideCurrentSnackBar();
                    messenger
                        .showSnackBar(SnackBar(content: Text(e.message)));
                  }
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.po, required this.poId});

  final PurchaseOrder po;
  final String poId;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  late PaymentStatus _status = widget.po.paymentStatus == PaymentStatus.unpaid
      ? PaymentStatus.dp
      : PaymentStatus.paid;
  late final _amount = TextEditingController(
      text: widget.po.paidAmount > 0
          ? widget.po.paidAmount.toStringAsFixed(0)
          : '');
  late final _method =
      TextEditingController(text: widget.po.paymentMethod ?? '');
  bool _submitting = false;

  @override
  void dispose() {
    _amount.dispose();
    _method.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = _status == PaymentStatus.paid
        ? widget.po.total
        : double.tryParse(_amount.text.replaceAll('.', '')) ?? 0;
    setState(() => _submitting = true);
    try {
      await ref.read(poDetailProvider(widget.poId).notifier).updatePayment(
            paymentStatus: _status,
            paidAmount: amount,
            paymentMethod:
                _method.text.trim().isEmpty ? null : _method.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Perbarui Pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Total: ${formatRupiah(widget.po.total)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SegmentedButton<PaymentStatus>(
            segments: const [
              ButtonSegment(value: PaymentStatus.dp, label: Text('DP')),
              ButtonSegment(value: PaymentStatus.paid, label: Text('Lunas')),
            ],
            selected: {_status},
            onSelectionChanged: (s) => setState(() => _status = s.first),
          ),
          const SizedBox(height: 12),
          if (_status == PaymentStatus.dp)
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Jumlah DP', prefixText: 'Rp '),
            ),
          if (_status == PaymentStatus.dp) const SizedBox(height: 12),
          TextField(
            controller: _method,
            decoration: const InputDecoration(
                labelText: 'Metode pembayaran',
                hintText: 'Transfer BCA / Tunai / QRIS'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('Simpan Pembayaran'),
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
      {required this.label, required this.value, this.bold = false});

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      fontSize: 13,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(formatRupiah(value), style: style)],
      ),
    );
  }
}
