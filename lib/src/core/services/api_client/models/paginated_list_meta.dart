class PaginatedListMeta {
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedListMeta({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
}
