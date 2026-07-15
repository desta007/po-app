import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_states.dart';
import '../data/po_models.dart';
import '../providers/po_providers.dart';
import 'widgets/po_badges.dart';

class PoListScreen extends ConsumerStatefulWidget {
  const PoListScreen({super.key});

  @override
  ConsumerState<PoListScreen> createState() => _PoListScreenState();
}

class _PoListScreenState extends ConsumerState<PoListScreen> {
  Timer? _debounce;
  bool _appliedQueryFilter = false;

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

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Order')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/po/create'),
        child: const Icon(Icons.add),
      ),
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
                      return _PoCard(po: state.items[index]);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
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
  const _PoCard({required this.po});

  final PurchaseOrder po;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/po/${po.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
