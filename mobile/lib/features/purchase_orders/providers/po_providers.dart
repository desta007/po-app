import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/providers/paged_list.dart';
import '../data/po_models.dart';
import '../data/purchase_orders_api.dart';

final poListProvider =
    NotifierProvider<PoListNotifier, PagedListState<PurchaseOrder>>(
        PoListNotifier.new);

class PoListNotifier extends Notifier<PagedListState<PurchaseOrder>> {
  PoFilters _filters = const PoFilters();
  int _requestId = 0;

  PoFilters get filters => _filters;
  PurchaseOrdersApi get _api => ref.read(purchaseOrdersApiProvider);

  @override
  PagedListState<PurchaseOrder> build() {
    Future.microtask(refresh);
    return const PagedListState(isLoading: true);
  }

  Future<void> refresh() async {
    final id = ++_requestId;
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final result = await _api.list(filters: _filters, page: 1);
      if (id != _requestId) return;
      state = PagedListState.firstPage(result);
    } on ApiException catch (e) {
      if (id != _requestId) return;
      state = state.copyWith(isLoading: false, error: () => e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final id = ++_requestId;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _api.list(filters: _filters, page: state.page + 1);
      if (id != _requestId) return;
      state = state.appendPage(result);
    } on ApiException {
      if (id != _requestId) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setFilters(PoFilters filters) {
    if (filters == _filters) return;
    _filters = filters;
    refresh();
  }

  void setSearch(String value) =>
      setFilters(_filters.copyWith(search: value));
}

/// Detail PO + seluruh aksinya. Setiap aksi memakai response server sebagai
/// state baru dan menyegarkan list di belakang layar.
final poDetailProvider = AsyncNotifierProvider.family<PoDetailNotifier,
    PurchaseOrder, String>(PoDetailNotifier.new);

class PoDetailNotifier extends AsyncNotifier<PurchaseOrder> {
  PoDetailNotifier(this.poId);

  final String poId;

  PurchaseOrdersApi get _api => ref.read(purchaseOrdersApiProvider);

  @override
  Future<PurchaseOrder> build() => _api.show(poId);

  Future<void> updateStatus(PoStatus status, {String? reason}) async {
    final po = await _api.updateStatus(poId, status, reason: reason);
    state = AsyncData(po);
    ref.read(poListProvider.notifier).refresh();
  }

  Future<void> updatePayment({
    required PaymentStatus paymentStatus,
    required double paidAmount,
    String? paymentMethod,
  }) async {
    final po = await _api.updatePayment(
      poId,
      paymentStatus: paymentStatus,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
    );
    state = AsyncData(po);
    ref.read(poListProvider.notifier).refresh();
  }

  Future<void> cancel({String? reason}) async {
    final po = await _api.cancel(poId, reason: reason);
    state = AsyncData(po);
    ref.read(poListProvider.notifier).refresh();
  }

  /// Duplikat PO, kembalikan PO baru (untuk navigasi ke detailnya).
  Future<PurchaseOrder> duplicate() async {
    final po = await _api.duplicate(poId);
    ref.read(poListProvider.notifier).refresh();
    return po;
  }
}
