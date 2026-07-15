import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/providers/paged_list.dart';
import '../data/product_models.dart';
import '../data/products_api.dart';

final productListProvider =
    NotifierProvider<ProductListNotifier, PagedListState<Product>>(
        ProductListNotifier.new);

class ProductListNotifier extends Notifier<PagedListState<Product>> {
  String _search = '';
  int _requestId = 0;

  ProductsApi get _api => ref.read(productsApiProvider);

  @override
  PagedListState<Product> build() {
    Future.microtask(refresh);
    return const PagedListState(isLoading: true);
  }

  Future<void> refresh() async {
    final id = ++_requestId;
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final result = await _api.list(search: _search, page: 1);
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

  Future<Product> create(ProductInput input, {String? imagePath}) async {
    final product = await _api.create(input);
    if (imagePath != null) {
      await _api.uploadImage(product.id, imagePath);
    }
    await refresh();
    return product;
  }

  Future<Product> update(String id, ProductInput input,
      {String? imagePath}) async {
    final product = await _api.update(id, input);
    if (imagePath != null) {
      await _api.uploadImage(id, imagePath);
    }
    await refresh();
    return product;
  }

  Future<void> delete(String id) async {
    await _api.delete(id);
    state = state.copyWith(
        items: state.items.where((p) => p.id != id).toList());
  }
}
