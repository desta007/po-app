/// Response paginasi Laravel: `{ data: [...], meta: { current_page, ... } }`.
class Paginated<T> {
  const Paginated({required this.items, required this.meta});

  final List<T> items;
  final PageMeta meta;

  bool get hasMore => meta.currentPage < meta.lastPage;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final data = (json['data'] as List? ?? const [])
        .map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();
    return Paginated(
      items: data,
      meta: PageMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class PageMeta {
  const PageMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  factory PageMeta.fromJson(Map<String, dynamic> json) => PageMeta(
        currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
        lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
        perPage: (json['per_page'] as num?)?.toInt() ?? 15,
        total: (json['total'] as num?)?.toInt() ?? 0,
      );
}
