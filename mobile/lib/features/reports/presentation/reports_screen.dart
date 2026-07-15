import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_states.dart';
import '../../dashboard/presentation/dashboard_screen.dart'
    show RevenueLineChart;
import '../data/report_models.dart';
import '../data/reports_api.dart';

enum _Preset {
  last30('30 Hari', 'daily'),
  last90('90 Hari', 'weekly'),
  thisYear('Tahun Ini', 'monthly');

  const _Preset(this.label, this.period);

  final String label;
  final String period;

  ReportRange toRange() {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    final start = switch (this) {
      last30 => now.subtract(const Duration(days: 30)),
      last90 => now.subtract(const Duration(days: 90)),
      thisYear => DateTime(now.year, 1, 1),
    };
    return ReportRange(
        period: period, start: fmt.format(start), end: fmt.format(now));
  }
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _Preset _preset = _Preset.last30;

  @override
  Widget build(BuildContext context) {
    final range = _preset.toRange();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Omzet'), Tab(text: 'Laba')],
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  for (final preset in _Preset.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(preset.label),
                        selected: _preset == preset,
                        onSelected: (_) => setState(() => _preset = preset),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _RevenueTab(range: range),
                  _ProfitTab(range: range),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueTab extends ConsumerWidget {
  const _RevenueTab({required this.range});

  final ReportRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(revenueReportProvider(range));

    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorRetryView(
        message: e is ApiException ? e.message : 'Gagal memuat laporan.',
        onRetry: () => ref.invalidate(revenueReportProvider(range)),
      ),
      data: (points) {
        final totalRevenue =
            points.fold<double>(0, (sum, p) => sum + p.revenue);
        final totalOrders = points.fold<int>(0, (sum, p) => sum + p.count);
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(revenueReportProvider(range));
            await ref.read(revenueReportProvider(range).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                      child: _SummaryTile(
                          label: 'Total Omzet',
                          value: formatRupiah(totalRevenue))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _SummaryTile(
                          label: 'PO Selesai', value: '$totalOrders')),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    height: 220,
                    child: points.isEmpty
                        ? const Center(
                            child: Text('Belum ada PO selesai pada periode ini',
                                style: TextStyle(
                                    color: AppColors.textSecondary)))
                        : RevenueLineChart(points: points),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (points.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rincian per Periode',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        for (final p in points.reversed.take(31))
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Expanded(child: Text(p.date)),
                                Text('${p.count} PO',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                const SizedBox(width: 12),
                                Text(formatRupiah(p.revenue),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfitTab extends ConsumerWidget {
  const _ProfitTab({required this.range});

  final ReportRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profitReportProvider(range));

    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorRetryView(
        message: e is ApiException ? e.message : 'Gagal memuat laporan.',
        onRetry: () => ref.invalidate(profitReportProvider(range)),
      ),
      data: (report) {
        final summary = report.summary ?? const ProfitSummary();
        final margin = summary.totalRevenue > 0
            ? (summary.totalProfit / summary.totalRevenue * 100)
            : 0.0;
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(profitReportProvider(range));
            await ref.read(profitReportProvider(range).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                      child: _SummaryTile(
                          label: 'Omzet',
                          value: formatRupiah(summary.totalRevenue))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _SummaryTile(
                          label: 'Modal (HPP)',
                          value: formatRupiah(summary.totalCost))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _SummaryTile(
                    label: 'Laba',
                    value: formatRupiah(summary.totalProfit),
                    valueColor: summary.totalProfit >= 0
                        ? AppColors.accent
                        : AppColors.danger,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _SummaryTile(
                          label: 'Margin',
                          value: '${margin.toStringAsFixed(1)}%')),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Laba per Periode',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: report.chart.isEmpty
                            ? const Center(
                                child: Text('Belum ada data',
                                    style: TextStyle(
                                        color: AppColors.textSecondary)))
                            : _ProfitBarChart(points: report.chart),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (report.topProducts.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Produk Paling Menguntungkan',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        for (final p in report.topProducts)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text(
                                        'Omzet ${formatRupiah(p.revenue)} · Modal ${formatRupiah(p.cost)}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color:
                                                AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatRupiah(p.profit),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: p.profit >= 0
                                        ? AppColors.accent
                                        : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfitBarChart extends StatelessWidget {
  const _ProfitBarChart({required this.points});

  final List<ProfitDataPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxProfit = points
        .map((p) => p.profit.abs())
        .fold<double>(0, (a, b) => a > b ? a : b);
    final compact = NumberFormat.compactCurrency(
        locale: 'id_ID', symbol: '', decimalDigits: 0);

    return BarChart(
      BarChartData(
        maxY: maxProfit <= 0 ? 1 : maxProfit * 1.2,
        minY: points.any((p) => p.profit < 0) ? -maxProfit * 1.2 : 0,
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
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    points[index].date.length > 5
                        ? points[index].date.substring(5)
                        : points[index].date,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              '${points[groupIndex].date}\nLaba ${formatRupiah(rod.toY)}',
              const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: points[i].profit,
                width: (300 / points.length).clamp(3, 18),
                color: points[i].profit >= 0
                    ? AppColors.accent
                    : AppColors.danger,
                borderRadius: BorderRadius.circular(2),
              ),
            ]),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile(
      {required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: valueColor)),
            ),
          ],
        ),
      ),
    );
  }
}
