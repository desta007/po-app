import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_states.dart';
import '../../settings/data/settings_api.dart';
import '../../settings/data/settings_models.dart';
import '../data/po_models.dart';
import '../data/purchase_orders_api.dart';
import '../providers/po_providers.dart';
import '../services/po_share_service.dart';
import '../services/thermal_printer_service.dart';
import 'widgets/label_size_sheet.dart';
import 'widgets/po_badges.dart';
import 'widgets/thermal_print_sheet.dart';

class PoListScreen extends ConsumerStatefulWidget {
  const PoListScreen({super.key});

  @override
  ConsumerState<PoListScreen> createState() => _PoListScreenState();
}

class _PoListScreenState extends ConsumerState<PoListScreen> {
  Timer? _debounce;
  bool _appliedQueryFilter = false;

  // Mode seleksi untuk cetak massal (struk / corporate / label).
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;
  bool _bulkBusy = false;

  void _enterSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (!_selectedIds.remove(id)) _selectedIds.add(id);
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
  }

  /// Pilih semua PO yang termuat, atau batalkan bila sudah semua terpilih.
  void _toggleSelectAll(List<PurchaseOrder> items) {
    setState(() {
      if (_selectedIds.length == items.length) {
        _selectedIds.clear();
        _selectionMode = false;
      } else {
        _selectedIds
          ..clear()
          ..addAll(items.map((e) => e.id));
      }
    });
  }

  Future<void> _runBulk(Future<void> Function() action) async {
    if (_selectedIds.isEmpty || _bulkBusy) return;
    setState(() => _bulkBusy = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Menyiapkan file…')));
    try {
      await action();
      messenger.hideCurrentSnackBar();
      if (mounted) _exitSelection();
    } on ApiException catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _bulkBusy = false);
    }
  }

  Future<void> _bulkPrintPdf(PoBulkPdfFormat format) => _runBulk(() => ref
      .read(poShareServiceProvider)
      .shareBulkPdf(ids: _selectedIds.toList(), format: format));

  Future<void> _bulkPrintLabels() async {
    if (_selectedIds.isEmpty || _bulkBusy) return;
    final size = await showLabelSizeSheet(context);
    if (size == null) return;
    await _runBulk(() => ref
        .read(poShareServiceProvider)
        .shareLabels(ids: _selectedIds.toList(), size: size));
  }

  Future<void> _bulkPrintAddressLabels() async {
    if (_selectedIds.isEmpty || _bulkBusy) return;
    final size = await showAddressLabelSizeSheet(context);
    if (size == null) return;
    await _runBulk(() => ref
        .read(poShareServiceProvider)
        .shareAddressLabels(ids: _selectedIds.toList(), size: size));
  }

  Future<void> _bulkPrintThermal() async {
    if (_selectedIds.isEmpty || _bulkBusy) return;
    final orders = ref
        .read(poListProvider)
        .items
        .where((p) => _selectedIds.contains(p.id))
        .toList();
    if (orders.isEmpty) return;
    await showThermalPrintSheet(
      context,
      count: orders.length,
      onPrint: () async {
        Organization? org;
        try {
          org = await ref.read(organizationProvider.future);
        } catch (_) {
          org = null;
        }
        await ref
            .read(thermalPrinterProvider.notifier)
            .printReceipts(orders, org);
      },
    );
  }

  Widget _buildBulkBar() {
    final enabled = _selectedIds.isNotEmpty && !_bulkBusy;
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _BulkAction(
                icon: Icons.receipt_long_outlined,
                label: 'Struk',
                enabled: enabled,
                onTap: () => _bulkPrintPdf(PoBulkPdfFormat.receipt),
              ),
              _BulkAction(
                icon: Icons.description_outlined,
                label: 'Corporate',
                enabled: enabled,
                onTap: () => _bulkPrintPdf(PoBulkPdfFormat.corporate),
              ),
              _BulkAction(
                icon: Icons.label_outline,
                label: 'Label',
                enabled: enabled,
                onTap: _bulkPrintLabels,
              ),
              _BulkAction(
                icon: Icons.local_shipping_outlined,
                label: 'Alamat',
                enabled: enabled,
                onTap: _bulkPrintAddressLabels,
              ),
              _BulkAction(
                icon: Icons.print_outlined,
                label: 'Thermal',
                enabled: enabled,
                highlighted: true,
                onTap: _bulkPrintThermal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dukung navigasi '/purchase-orders?customer_id=...' dari detail pelanggan.
    if (_appliedQueryFilter) return;
    _appliedQueryFilter = true;
    final customerId =
        GoRouterState.of(context).uri.queryParameters['customer_id'];
    if (customerId != null && customerId.isNotEmpty) {
      Future.microtask(() {
        if (!mounted) return;
        final notifier = ref.read(poListProvider.notifier);
        notifier.setFilters(
            notifier.filters.copyWith(customerId: () => customerId));
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(poListProvider.notifier).setSearch(value.trim());
    });
  }

  Future<void> _exportExcel() async {
    final notifier = ref.read(poListProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
        const SnackBar(content: Text('Menyiapkan file Excel…')));
    try {
      await ref.read(poShareServiceProvider).shareExcel(
            filters: notifier.filters,
            sortBy: notifier.sortBy,
            sortDir: notifier.sortDir,
          );
      messenger.hideCurrentSnackBar();
    } on ApiException catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(poListProvider);
    final notifier = ref.read(poListProvider.notifier);
    final filters = notifier.filters;

    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitSelection();
      },
      child: Scaffold(
      appBar: _selectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelection,
              ),
              title: Text('${_selectedIds.length} dipilih'),
              actions: [
                TextButton(
                  onPressed: () => _toggleSelectAll(state.items),
                  child: Text(
                    _selectedIds.length == state.items.length &&
                            state.items.isNotEmpty
                        ? 'Batal semua'
                        : 'Pilih semua',
                  ),
                ),
              ],
            )
          : AppBar(
              title: const Text('Purchase Order'),
              actions: [
                IconButton(
                  tooltip: 'Export Excel',
                  icon: const Icon(Icons.file_download_outlined),
                  onPressed: _exportExcel,
                ),
                IconButton(
                  tooltip: 'Filter & urutkan',
                  icon: Badge(
                    isLabelVisible: filters.hasActiveFilters,
                    smallSize: 8,
                    child: const Icon(Icons.tune),
                  ),
                  onPressed: () => _showFilterSheet(context),
                ),
                IconButton(
                  tooltip: 'Pilih untuk cetak',
                  icon: const Icon(Icons.checklist),
                  onPressed: () => setState(() => _selectionMode = true),
                ),
              ],
            ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/po/create'),
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: _selectionMode ? _buildBulkBar() : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Cari no. PO / nama pelanggan…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _StatusFilterChip(
                  label: 'Semua',
                  selected: filters.status == null,
                  onSelected: () =>
                      notifier.setFilters(filters.copyWith(status: () => null)),
                ),
                for (final status in PoStatus.values)
                  _StatusFilterChip(
                    label: status.label,
                    color: status.color,
                    selected: filters.status == status,
                    onSelected: () => notifier
                        .setFilters(filters.copyWith(status: () => status)),
                  ),
              ],
            ),
          ),
          if (filters.customerId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: const Text('Filter: pelanggan tertentu'),
                  onDeleted: () => notifier
                      .setFilters(filters.copyWith(customerId: () => null)),
                ),
              ),
            ),
          Expanded(
            child: Builder(builder: (context) {
              if (state.isLoading) return const LoadingView();
              if (state.error != null) {
                return ErrorRetryView(
                    message: state.error!, onRetry: notifier.refresh);
              }
              if (state.isEmpty) {
                return const EmptyView(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada purchase order',
                  subtitle: 'Buat PO pertama Anda dengan tombol +',
                );
              }
              return RefreshIndicator(
                onRefresh: notifier.refresh,
                child: InfiniteScrollListener(
                  onLoadMore: notifier.loadMore,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount:
                        state.items.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const LoadMoreIndicator();
                      }
                      final po = state.items[index];
                      return _PoCard(
                        po: po,
                        selectionMode: _selectionMode,
                        selected: _selectedIds.contains(po.id),
                        onTap: () => _selectionMode
                            ? _toggleSelected(po.id)
                            : context.push('/po/${po.id}'),
                        onLongPress: () => _enterSelection(po.id),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      ),
    );
  }
}

/// Opsi urut daftar PO — nilai sama dengan `allowedSorts` di backend.
const _sortOptions = <String, String>{
  'created_at': 'Tanggal Dibuat',
  'order_date': 'Tgl Order',
  'delivery_date': 'Tgl Kirim',
  'total': 'Total',
  'po_number': 'No. PO',
};

/// Sheet filter & urutan: sumber, status pembayaran, dan pengurutan.
/// Selaras dengan filter di daftar PO web (source + payment_status + sort).
class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch agar sheet ikut refresh saat pilihan berubah.
    ref.watch(poListProvider);
    final notifier = ref.read(poListProvider.notifier);
    final filters = notifier.filters;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Filter & Urutkan',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                if (filters.hasActiveFilters ||
                    notifier.sortBy != 'created_at' ||
                    notifier.sortDir != 'desc')
                  TextButton(
                    onPressed: () {
                      notifier.setFilters(PoFilters(search: filters.search));
                      notifier.setSort('created_at', 'desc');
                    },
                    child: const Text('Reset'),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            const _SheetLabel('Sumber'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: filters.source == null,
                  onSelected: (_) =>
                      notifier.setFilters(filters.copyWith(source: () => null)),
                ),
                for (final s in PoSource.values)
                  ChoiceChip(
                    label: Text(s.label),
                    selected: filters.source == s,
                    onSelected: (_) => notifier
                        .setFilters(filters.copyWith(source: () => s)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const _SheetLabel('Status Pembayaran'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: filters.paymentStatus == null,
                  onSelected: (_) => notifier
                      .setFilters(filters.copyWith(paymentStatus: () => null)),
                ),
                for (final p in PaymentStatus.values)
                  ChoiceChip(
                    label: Text(p.label),
                    selected: filters.paymentStatus == p,
                    onSelected: (_) => notifier
                        .setFilters(filters.copyWith(paymentStatus: () => p)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const _SheetLabel('Urutkan berdasarkan'),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in _sortOptions.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: notifier.sortBy == entry.key,
                    onSelected: (_) =>
                        notifier.setSort(entry.key, notifier.sortDir),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'desc',
                    label: Text('Terbaru'),
                    icon: Icon(Icons.arrow_downward, size: 16)),
                ButtonSegment(
                    value: 'asc',
                    label: Text('Terlama'),
                    icon: Icon(Icons.arrow_upward, size: 16)),
              ],
              selected: {notifier.sortDir},
              onSelectionChanged: (s) =>
                  notifier.setSort(notifier.sortBy, s.first),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

/// Aksi cetak massal: ikon di atas, label ringkas di bawah (satu baris, tidak
/// terpotong). [highlighted] menandai aksi utama (Thermal).
class _BulkAction extends StatelessWidget {
  const _BulkAction({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final active = highlighted ? AppColors.primary : AppColors.textPrimary;
    final color = enabled ? active : AppColors.textSecondary.withValues(alpha: 0.5);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: highlighted && enabled
                ? AppColors.primary.withValues(alpha: 0.10)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.15),
        checkmarkColor: color ?? AppColors.primary,
      ),
    );
  }
}

class _PoCard extends StatelessWidget {
  const _PoCard({
    required this.po,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final PurchaseOrder po;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selectionMode) ...[
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      po.poNumber,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  PoStatusBadge(status: po.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                po.customer?.name ?? '-',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    'Kirim ${formatDateString(po.deliveryDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  PaymentStatusBadge(status: po.paymentStatus),
                  const SizedBox(width: 8),
                  Text(
                    formatRupiah(po.total),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
