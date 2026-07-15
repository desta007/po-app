import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/providers/paged_list.dart';
import '../data/customer_models.dart';
import '../data/customers_api.dart';

final customerListProvider =
    NotifierProvider<CustomerListNotifier, PagedListState<Customer>>(
        CustomerListNotifier.new);

class CustomerListNotifier extends Notifier<PagedListState<Customer>> {
  String _search = '';
  int _requestId = 0;

  CustomersApi get _api => ref.read(customersApiProvider);

  @override
  PagedListState<Customer> build() {
    Future.microtask(refresh);
    return const PagedListState(isLoading: true);
  }

  Future<void> refresh() async {
    final id = ++_requestId;
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final result = await _api.list(search: _search, page: 1);
      if (id != _requestId) return; // sudah ada request lebih baru
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
      final result = await _api.list(search: _search, page: state.page + 1);
      if (id != _requestId) return;
      state = state.appendPage(result);
    } on ApiException {
      if (id != _requestId) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    refresh();
  }

  Future<Customer> create(CustomerInput input) async {
    final customer = await _api.create(input);
    await refresh();
    return customer;
  }

  Future<Customer> update(String id, CustomerInput input) async {
    final customer = await _api.update(id, input);
    await refresh();
    ref.invalidate(customerDetailProvider(id));
    return customer;
  }

  Future<void> delete(String id) async {
    await _api.delete(id);
    state = state.copyWith(
        items: state.items.where((c) => c.id != id).toList());
  }
}

final customerDetailProvider = FutureProvider.family<Customer, String>(
    (ref, id) => ref.watch(customersApiProvider).show(id));
