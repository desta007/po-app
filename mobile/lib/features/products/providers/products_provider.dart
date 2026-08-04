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
  String? _category;
  int _requestId = 0;

  /// Kumpulan kategori yang pernah termuat, jadi opsi filter tetap tersedia
  /// walau daftar sedang tersaring per kategori.
  final Set<String> _knownCategories = {};

  String? get category => _category;
  List<String> get knownCategories => _knownCategories.toList()..sort();

  ProductsApi get _api => ref.read(productsApiProvider);

  void _rememberCategories(Iterable<Product> products) {
    for (final p in products) {
      final c = p.category;
      if (c != null && c.trim().isNotEmpty) _knownCategories.add(c.trim());
    }
  }

  @override
  PagedListState<Product> build() {
    Future.microtask(refresh);
    return const PagedListState(isLoading: true);
  }

  Future<void> refresh() async {
    final id = ++_requestId;
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final result =
          await _api.list(search: _search, category: _category, page: 1);
      if (id != _requestId) return;
      _rememberCategories(result.items);
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
      final result = await _api.list(
          search: _search, category: _category, page: state.page + 1);
      if (id != _requestId) return;
      _rememberCategories(result.items);
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

  void setCategory(String? value) {
    final normalized = (value == null || value.isEmpty) ? null : value;
    if (normalized == _category) return;
    _category = normalized;
    refresh();
  }

  Future<Product> create(ProductInput input,
      {List<String> imagePaths = const []}) async {
    final product = await _api.create(input);
    if (imagePaths.isNotEmpty) {
      await _api.uploadImages(product.id, imagePaths);
    }
    await refresh();
    return product;
  }

  Future<Product> update(String id, ProductInput input,
      {List<String> imagePaths = const []}) async {
    final product = await _api.update(id, input);
    if (imagePaths.isNotEmpty) {
      await _api.uploadImages(id, imagePaths);
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
