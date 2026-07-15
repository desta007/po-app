import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_states.dart';
import '../data/subscription_api.dart';
import '../data/subscription_models.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final quotaAsync = ref.watch(quotaUsageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Langganan & Kuota')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(subscriptionStatusProvider);
          ref.invalidate(quotaUsageProvider);
          await ref.read(subscriptionStatusProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            statusAsync.when(
              loading: () => const Card(
                  child: SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()))),
              error: (e, _) => ErrorRetryView(
                message:
                    e is ApiException ? e.message : 'Gagal memuat status.',
                onRetry: () => ref.invalidate(subscriptionStatusProvider),
              ),
              data: (status) => _StatusCard(status: status),
            ),
            const SizedBox(height: 12),
            quotaAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (quota) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pemakaian Kuota',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _QuotaBar(label: 'PO bulan ini', item: quota.poMonthly),
                      _QuotaBar(label: 'Produk', item: quota.products),
                      _QuotaBar(
                          label: 'Anggota tim', item: quota.teamMembers),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends ConsumerWidget {
  const _StatusCard({required this.status});

  final SubscriptionStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = status.latestSubscription;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.isPremium
                      ? Icons.workspace_premium
                      : Icons.workspace_premium_outlined,
                  color: status.isPremium
                      ? AppColors.warning
                      : AppColors.textSecondary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paket ${status.planLabel}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    if (latest?.isActive == true &&
                        latest?.expiresAt != null)
                      Text(
                        'Aktif s/d ${formatDateString(latest!.expiresAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (latest?.isPending == true)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_top,
                        size: 18, color: AppColors.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Permintaan upgrade sedang menunggu persetujuan admin.'),
                    ),
                  ],
                ),
              )
            else if (latest?.status == 'rejected')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                    'Permintaan sebelumnya ditolak${latest?.rejectReason != null ? ': ${latest!.rejectReason}' : '.'}'),
              ),
            const SizedBox(height: 12),
            if (!status.isPremium && latest?.isPending != true)
              FilledButton.icon(
                onPressed: () => _requestUpgrade(context, ref),
                icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                label: const Text('Upgrade ke Premium'),
              ),
            if (latest != null && latest.isActive)
              OutlinedButton.icon(
                onPressed: () => _shareInvoice(context, ref, latest.id),
                icon: const Icon(Icons.receipt_outlined, size: 18),
                label: const Text('Unduh Invoice'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestUpgrade(BuildContext context, WidgetRef ref) async {
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upgrade ke Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Permintaan akan diverifikasi admin. Sertakan catatan bukti pembayaran bila ada.'),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  hintText: 'Transfer via BCA a.n. ... tanggal ...'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Kirim Permintaan')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(subscriptionApiProvider).requestUpgrade(
          note: note.text.trim().isEmpty ? null : note.text.trim());
      ref.invalidate(subscriptionStatusProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Permintaan upgrade terkirim.')));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _shareInvoice(
      BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
        const SnackBar(content: Text('Menyiapkan invoice…')));
    try {
      final bytes =
          await ref.read(subscriptionApiProvider).downloadInvoice(id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice-$id.pdf');
      await file.writeAsBytes(bytes, flush: true);
      messenger.hideCurrentSnackBar();
      await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path)], subject: 'Invoice Langganan'));
    } on ApiException catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _QuotaBar extends StatelessWidget {
  const _QuotaBar({required this.label, required this.item});

  final String label;
  final QuotaItem item;

  @override
  Widget build(BuildContext context) {
    final nearLimit = !item.isUnlimited && item.ratio >= 0.8;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                item.isUnlimited
                    ? '${item.current} / ∞'
                    : '${item.current} / ${item.limit}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: nearLimit ? AppColors.danger : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.isUnlimited ? 0.05 : item.ratio,
              minHeight: 8,
              backgroundColor: AppColors.border,
              color: nearLimit ? AppColors.danger : AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
