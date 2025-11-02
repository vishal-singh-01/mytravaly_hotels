import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/bootstrap_controller.dart';
import '../data/search_repository.dart';
import '../../../models/autocomplete_item.dart';
import '../../../models/hotel.dart';
import '../../../models/search_result_model.dart' as model;
import '../../../models/search_criteria.dart';


final dioClientProvider = Provider((ref) => DioClient.create());
final searchRepositoryProvider = Provider((ref) => SearchRepository(ref.read(dioClientProvider)));
final searchCriteriaProvider = StateProvider<SearchCriteria?>((_) => null);

final structuredSuggestionsProvider =
FutureProvider.family.autoDispose<List<AutoCompleteItem>, String>((ref, q) async {
  final query = q.trim();
  if (query.isEmpty) return const [];
  final token = ref.read(visitorTokenProvider) ?? '';
  if (token.isEmpty) return const [];
  final repo = ref.read(searchRepositoryProvider);
  return repo.autocompleteStructured(inputText: query, visitorToken: token);
});


final suggestionsProvider = FutureProvider.family.autoDispose<List<String>, String>((ref, q) async {
  if (q.trim().isEmpty) return [];
  final visitorToken = ref.watch(visitorTokenProvider);

  return ref.read(searchRepositoryProvider).autocomplete(
    inputText: q,
    visitorToken: visitorToken ?? "",
  );
});


class PagingState {
  final List<Hotel> items;
  final bool loading;
  final bool error;
  final String? message;
  final int page;
  final bool hasMore;


  const PagingState({
    this.items = const [],
    this.loading = false,
    this.error = false,
    this.message,
    this.page = 1,
    this.hasMore = true,
  });


  PagingState copyWith({List<Hotel>? items, bool? loading, bool? error, String? message, int? page, bool? hasMore}) =>
      PagingState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        error: error ?? this.error,
        message: message,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
      );
}


final searchPagingProvider = StateNotifierProvider.autoDispose<SearchPagingController, PagingState>((ref) {
  return SearchPagingController(ref);
});


class SearchPagingController extends StateNotifier<PagingState> {
  SearchPagingController(this.ref) : super(const PagingState());
  final Ref ref;
  String _currentQuery = '';
  SearchCriteria? _criteria;


  void resetWithCriteria(SearchCriteria criteria) {
    _criteria = criteria;
    ref.read(searchCriteriaProvider.notifier).state = criteria;
    state = const PagingState();
    fetchNext();
  }

  void reset(String q) {
    final now = DateTime.now();
    final cIn = now.add(const Duration(days: 3));
    final cOut = now.add(const Duration(days: 4));
    resetWithCriteria(SearchCriteria(
      checkIn: cIn.toIso8601String().substring(0, 10),
      checkOut: cOut.toIso8601String().substring(0, 10),
      searchType: 'citySearch',
      searchQuery: [q],
    ));
  }

  Future<void> fetchNext() async {
    if (state.loading || !state.hasMore) return;

    print("fetchNext called");
    final token = ref.read(visitorTokenProvider) ?? '';
    if (token.isEmpty) {
      state = state.copyWith(error: true, message: 'Not initialized (no visitor token)');
      return;
    }
    if (_criteria == null) {
      state = state.copyWith(error: true, message: 'No search criteria set');
      return;
    }

    state = state.copyWith(loading: true, error: false, message: null);

    try {
      final repo = ref.read(searchRepositoryProvider);
      final nextPage = state.page;

      final page = await repo.searchHotels(
        visitorToken: token,
        checkIn: _criteria!.checkIn,
        checkOut: _criteria!.checkOut,
        rooms: _criteria!.rooms,
        adults: _criteria!.adults,
        children: _criteria!.children,
        searchType: _criteria!.searchType,
        searchQuery: _criteria!.searchQuery,
        limit: 5,
        currency: _criteria!.currency,
        page: nextPage,
      );

      state = state.copyWith(
        items: [...state.items, ...page.items],
        page: nextPage + 1,
        hasMore: page.hasMore,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: true,
        message: e.toString(),
      );
    }
  }

}