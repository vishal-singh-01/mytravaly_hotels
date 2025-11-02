class SearchResultPageModel<T> {
  final List<T> items;
  final int page;
  final bool hasMore;


  SearchResultPageModel({required this.items, required this.page, required this.hasMore});
}