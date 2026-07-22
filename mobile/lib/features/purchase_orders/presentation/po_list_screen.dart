import 'dart:async';

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
import 'widgets/label_size_sheet.dart';
import 'widgets/po_badges.dart';

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

  Widget _buildBulkBar() {
    final enabled = _selectedIds.isNotEmpty && !_bulkBusy;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled
                    ? () => _bulkPrintPdf(PoBulkPdfFormat.receipt)
                    : null,
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: const Text('Struk'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled
                    ? () => _bulkPrintPdf(PoBulkPdfFormat.corporate)
                    : null,
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Corporate'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: enabled ? _bulkPrintLabels : null,
                icon: const Icon(Icons.label_outline, size: 18),
                label: const Text('Label'),
              ),
            ),
          ],
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
            notifier.filters.copyWith(customerId: customerId));
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
            )
          : AppBar(
              title: const Text('Purchase Order'),
              actions: [
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
                  onDeleted: () => notifier.setFilters(PoFilters(
                    search: filters.search,
                    status: filters.status,
                    paymentStatus: filters.paymentStatus,
                  )),
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
