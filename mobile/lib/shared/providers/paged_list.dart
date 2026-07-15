import '../../core/api/pagination.dart';

/// State list berpaginasi dengan infinite scroll + pull-to-refresh.
class PagedListState<T> {
  const PagedListState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.total = 0,
  });

  final List<T> items;
  final int page;
  final bool hasMore;

  /// Loading halaman pertama (initial / refresh / ganti filter).
  final bool isLoading;

  /// Loading halaman berikutnya (scroll ke bawah).
  final bool isLoadingMore;
  final String? error;
  final int total;

  bool get isEmpty => !isLoading && error == null && items.isEmpty;

  PagedListState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? Function()? error,
    int? total,
  }) =>
      PagedListState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error != null ? error() : this.error,
        total: total ?? this.total,
      );

  PagedListState<T> appendPage(Paginated<T> result) => copyWith(
        items: [...items, ...result.items],
        page: result.meta.currentPage,
        hasMore: result.hasMore,
        isLoading: false,
        isLoadingMore: false,
        error: () => null,
        total: result.meta.total,
      );

  static PagedListState<T> firstPage<T>(Paginated<T> result) =>
      PagedListState<T>(
        items: result.items,
        page: result.meta.currentPage,
        hasMore: result.hasMore,
        total: result.meta.total,
      );
}
