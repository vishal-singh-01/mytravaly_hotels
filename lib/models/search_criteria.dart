class SearchCriteria {
  final String checkIn;
  final String checkOut;
  final int rooms;
  final int adults;
  final int children;
  final String searchType;
  final List<String> searchQuery;
  final String currency;
  final int limit;

  const SearchCriteria({
    required this.checkIn,
    required this.checkOut,
    this.rooms = 1,
    this.adults = 2,
    this.children = 0,
    required this.searchType,
    required this.searchQuery,
    this.currency = 'INR',
    this.limit = 5,
  });
}

