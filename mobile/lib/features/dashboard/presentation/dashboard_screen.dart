import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../data/dashboard_api.dart';
import '../data/dashboard_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(todaySummaryProvider);
    ref.invalidate(revenueChartProvider);
    ref.invalidate(topCustomersProvider);
    ref.invalidate(topProductsProvider);
    ref.invalidate(pendingPaymentsProvider);
    ref.invalidate(unreadCountProvider);
    await ref.read(todaySummaryProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaySummaryProvider);
    final chart = ref.watch(revenueChartProvider);
    final topCustomers = ref.watch(topCustomersProvider);
    final topProducts = ref.watch(topProductsProvider);
    final pending = ref.watch(pendingPaymentsProvider);
    final unread = ref.watch(unreadCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // Kartu ringkasan
            summary.when(
              loading: () => const _CardLoading(height: 120),
              error: (e, _) => _CardError(onRetry: () => _refresh(ref)),
              data: (s) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'PO Hari Ini',
                          value: '${s.totalPo}',
                          caption: s.poChange,
                          captionUp: s.poChangeUp,
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Omzet Bulan Ini',
                          value: formatRupiah(s.totalRevenue),
                          caption: s.revenueChange,
                          captionUp: s.revenueChangeUp,
                          icon: Icons.payments_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PO Bulan Ini (${s.totalOrdersThisMonth})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _StatusCount(
                                  label: 'Draft',
                                  count: s.draft,
                                  color: AppColors.textSecondary),
                              _StatusCount(
                                  label: 'Konfirmasi',
                                  count: s.confirmed,
                                  color: AppColors.secondary),
                              _StatusCount(
                                  label: 'Proses',
                                  count: s.inProgress,
                                  color: AppColors.warning),
                              _StatusCount(
                                  label: 'Selesai',
                                  count: s.completed,
                                  color: AppColors.accent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Pending payments
            pending.when(
              loading: () => const _CardLoading(height: 80),
              error: (e, _) => const SizedBox.shrink(),
              data: (p) => (p.totalUnpaid + p.totalDp) == 0
                  ? const SizedBox.shrink()
                  : Card(
                      color: AppColors.warningLight,
                      child: ListTile(
                        leading: const Icon(Icons.hourglass_bottom,
                            color: AppColors.warning),
                        title: Text(
                            '${p.totalUnpaid} PO belum bayar · ${p.totalDp} PO DP'),
                        subtitle: Text(
                            'Potensi tagihan ${formatRupiah(p.unpaidAmount + p.dpRemainingAmount)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/purchase-orders'),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            // Chart omzet 30 hari
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Omzet 30 Hari Terakhir',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: chart.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => const Center(
                            child: Text('Gagal memuat chart',
                                style: TextStyle(
                                    color: AppColors.textSecondary))),
                        data: (points) => points.isEmpty
                            ? const Center(
                                child: Text('Belum ada PO selesai',
                                    style: TextStyle(
                                        color: AppColors.textSecondary)))
                            : RevenueLineChart(points: points),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Top pelanggan & produk
            topCustomers.when(
              loading: () => const _CardLoading(height: 100),
              error: (e, _) => const SizedBox.shrink(),
              data: (customers) => _TopListCard(
                title: 'Top Pelanggan',
                icon: Icons.people_outline,
                rows: [
                  for (final c in customers)
                    (c.name, '${c.totalOrders} PO', formatRupiah(c.totalRevenue)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            topProducts.when(
              loading: () => const _CardLoading(height: 100),
              error: (e, _) => const SizedBox.shrink(),
              data: (products) => _TopListCard(
                title: 'Produk Terlaris (30 hari)',
                icon: Icons.inventory_2_outlined,
                rows: [
                  for (final p in products)
                    (
                      p.name,
                      '${p.totalQty % 1 == 0 ? p.totalQty.toInt() : p.totalQty} terjual',
                      formatRupiah(p.totalRevenue),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Line chart omzet harian dengan fl_chart.
class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({super.key, required this.points});

  final List<RevenueDataPoint> points;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].revenue),
    ];
    final maxY =
        points.map((p) => p.revenue).fold<double>(0, (a, b) => a > b ? a : b);
    final compact = NumberFormat.compactCurrency(
        locale: 'id_ID', symbol: '', decimalDigits: 0);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY <= 0 ? 1 : maxY * 1.2,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) => Text(
                compact.format(value),
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (points.length / 4).clamp(1, 30).toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                final date = DateTime.tryParse(points[index].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    date == null
                        ? points[index].date
                        : DateFormat('d/M').format(date),
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => [
              for (final spot in touched)
                LineTooltipItem(
                  '${points[spot.spotIndex].date}\n${formatRupiah(spot.y)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2.5,
            dotData: FlDotData(show: points.length <= 15),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.caption,
    this.captionUp = true,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? caption;
  final bool captionUp;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (caption != null) ...[
              const SizedBox(height: 4),
              Text(
                caption!,
                style: TextStyle(
                  fontSize: 11,
                  color: captionUp ? AppColors.accent : AppColors.danger,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  const _StatusCount(
      {required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TopListCard extends StatelessWidget {
  const _TopListCard(
      {required this.title, required this.icon, required this.rows});

  final String title;
  final IconData icon;
  final List<(String, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Belum ada data',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            for (final (name, sub, amount) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(sub,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(amount,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardLoading extends StatelessWidget {
  const _CardLoading({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Card(
        child: SizedBox(
          height: height,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ),
      );
}

class _CardError extends StatelessWidget {
  const _CardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Gagal memuat data dashboard.'),
              TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
}
