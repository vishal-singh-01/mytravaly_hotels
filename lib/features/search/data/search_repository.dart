import '../../../core/network/dio_client.dart';
import '../../../core/network/exceptions.dart';
import '../../../models/autocomplete_item.dart';
import '../../../models/hotel.dart';
import '../../../models/search_hotel.dart';
import '../../../models/search_result_model.dart';
import 'search_api.dart';

class SearchRepository {
  SearchRepository(DioClient client) : _api = SearchApi(client);
  final SearchApi _api;

  // ---------- REGISTER DEVICE ----------

  Future<String> registerDevice({
    required String deviceModel,
    required String deviceFingerprint,
    required String deviceBrand,
    required String deviceId,
    required String deviceName,
    required String deviceManufacturer,
    required String deviceProduct,
    required String deviceSerialNumber,
  }) async {
    try {
      final res = await _api.registerDevice(
        deviceModel: deviceModel,
        deviceFingerprint: deviceFingerprint,
        deviceBrand: deviceBrand,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceManufacturer: deviceManufacturer,
        deviceProduct: deviceProduct,
        deviceSerialNumber: deviceSerialNumber,
      );

      final root = res.data ?? {};
      final token = (root['data']?['visitor_token'] ??
          root['data']?['visitorToken'] ??
          root['visitor_token'] ??
          root['visitorToken'])
          ?.toString();

      if (token == null || token.isEmpty) {
        throw  AppException('Visitor token missing from response');
      }
      return token;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to register device');
    }
  }

  // ---------- AUTOCOMPLETE ----------

  Future<List<String>> autocomplete({
    required String inputText,
    required String visitorToken,
    List<String>? searchType,
    int limit = 10,
  }) async {
    try {
      final res = await _api.autocomplete(
        inputText: inputText,
        visitorToken: visitorToken,
        searchType: searchType,
        limit: limit,
      );

      final root = res.data ?? {};
      final data = root['data'] ?? root['searchAutoComplete'] ?? root;
      final list = (data is Map
          ? (data['suggestions'] ?? data['list'] ?? data['data'])
          : data) as List? ??
          const [];

      return list.map((e) => e.toString()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to fetch suggestions');
    }
  }

  // ---------- PROPERTY LIST ----------

  Future<List<Hotel>> propertyList({
    required String visitorToken,
    int limit = 10,
    String entityType = 'Any',
    String searchType = 'byCity',
    String? country,
    String? state,
    String? city,
    String currency = 'INR',
  }) async {
    try {
      final res = await _api.getPropertyList(
        visitorToken: visitorToken,
        limit: limit,
        entityType: entityType,
        searchType: searchType,
        country: country,
        state: state,
        city: city,
        currency: currency,
      );

      final items = _extractHotels(res.data, fallbackLimit: limit);
      return items;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to fetch properties');
    }
  }

  // ---------- SEARCH RESULTS ----------

  Future<SearchResultPageModel<Hotel>> searchHotels({
    required String visitorToken,
    required String checkIn,
    required String checkOut,
    int rooms = 1,
    int adults = 2,
    int children = 0,
    String searchType = 'hotelIdSearch',
    required List<String> searchQuery,
    List<String>? accommodation,
    List<String>? excludedSearchType,
    String highPrice = '3000000',
    String lowPrice = '0',
    int limit = 5,
    List<dynamic> preloaderList = const [],
    String currency = 'INR',
    int rid = 0,
    required int page,
  }) async {
    try {
      final res = await _api.getSearchResult(
        visitorToken: visitorToken,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: rooms,
        adults: adults,
        children: children,
        searchType: searchType,
        searchQuery: searchQuery,
        accommodation: accommodation,
        // excludedSearchType: excludedSearchType,
        highPrice: highPrice,
        lowPrice: lowPrice,
        limit: limit,
        preloaderList: preloaderList,
        currency: currency,
        rid: rid,
      );

      final root = res.data ?? const {};
      final data = (root['data'] as Map?) ?? const {};
      final list = (data['arrayOfHotelList'] as List?) ?? const [];

      final parsed = list
          .whereType<Map>()
          .map((m) => SearchHotel.fromJson(Map<String, dynamic>.from(m)).toHotel())
          .toList();

      final hasMore = parsed.length == limit;
      return SearchResultPageModel(items: parsed, page: page, hasMore: hasMore);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to fetch search results');
    }
  }

  // ---------- CURRENCIES ----------

  Future<List<Map<String, dynamic>>> currencyList({
    required String visitorToken,
    String baseCode = 'INR',
  }) async {
    try {
      final res = await _api.getCurrencyList(
        visitorToken: visitorToken,
        baseCode: baseCode,
      );

      final root = res.data ?? {};
      final data = root['data'] ??
          root['getCurrencyList'] ??
          root['currencies'] ??
          root;

      final list = (data is Map
          ? (data['list'] ??
          data['currencies'] ??
          data['data'] ??
          data['items'])
          : data) as List? ??
          const [];

      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to fetch currency list');
    }
  }

  // ---------- APP SETTINGS ----------

  Future<Map<String, dynamic>> appSettings() async {
    try {
      final res = await _api.getAppSettings();
      final root = res.data ?? {};
      final data = root['data'] ?? root['appSetting'] ?? root;
      return Map<String, dynamic>.from(data is Map ? data : {'data': data});
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to fetch app settings');
    }
  }


  List<Hotel> _extractHotels(
      Map<String, dynamic>? raw, {
        required int fallbackLimit,
      }) {
    final root = raw ?? const {};
    final data = root['data'] ??
        root['results'] ??
        root['popularStay'] ??
        root['getSearchResultListOfHotels'] ??
        root;

    if (data is Map && data['arrayOfHotelList'] is List) {
      return (data['arrayOfHotelList'] as List)
          .whereType<Map>()
          .map((e) => Hotel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    List listCandidate;
    if (data is List) {
      listCandidate = data;
    } else if (data is Map) {
      listCandidate = (data['results'] ??
          data['list'] ??
          data['hotels'] ??
          data['properties'] ??
          data['items'] ??
          data['data']) as List? ??
          const [];
    } else {
      listCandidate = const [];
    }

    return listCandidate
        .whereType<Map>()
        .map((e) => Hotel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

}


extension SearchRepositoryAutocomplete on SearchRepository {
  Future<List<AutoCompleteItem>> autocompleteStructured({
    required String inputText,
    required String visitorToken,
    int limit = 10,
  }) async {
    try {
      final res = await _api.autocomplete(
        inputText: inputText,
        visitorToken: visitorToken,
        limit: limit,
      );

      final root = res.data ?? {};
      final data = root['data'] as Map? ?? const {};
      final groups = data['autoCompleteList'] as Map? ?? const {};

      final items = <AutoCompleteItem>[];

      void readGroup(String groupKey) {
        final g = groups[groupKey] as Map?;
        if (g == null) return;
        final present = g['present'] == true;
        if (!present) return;
        final list = g['listOfResult'] as List? ?? const [];
        for (final raw in list) {
          if (raw is! Map) continue;
          final display = (raw['valueToDisplay'] ?? raw['propertyName'] ?? '').toString();

          String type = '';
          List<String> query = const [];
          final searchArray = raw['searchArray'] as Map?;
          if (searchArray != null) {
            type = (searchArray['type'] ?? '').toString();
            final q = searchArray['query'];
            if (q is List) {
              query = q.map((e) => e.toString()).toList();
            }
          }

          final addr = (raw['address'] as Map?) ?? const {};
          items.add(AutoCompleteItem(
            group: groupKey,
            display: display,
            type: type,
            query: query,
            city: addr['city']?.toString(),
            state: addr['state']?.toString(),
            country: addr['country']?.toString(),
          ));
        }
      }

      for (final key in const ['byPropertyName', 'byStreet', 'byCity', 'byState', 'byCountry']) {
        readGroup(key);
      }

      return items;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to fetch suggestions');
    }
  }
}
