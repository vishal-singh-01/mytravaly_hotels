import 'package:dio/dio.dart';
import '../../../core/env.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants.dart';


class SearchApi {
  SearchApi(this._client);
  final DioClient _client;

  // Register Device api call
  Future<Response<Map<String, dynamic>>> registerDevice({
    required String deviceModel,
    required String deviceFingerprint,
    required String deviceBrand,
    required String deviceId,
    required String deviceName,
    required String deviceManufacturer,
    required String deviceProduct,
    required String deviceSerialNumber,
  }) {
    final payload = {
      "action": Constants.registerDevice,
      "deviceRegister": {
        "deviceModel": deviceModel,
        "deviceFingerprint": deviceFingerprint,
        "deviceBrand": deviceBrand,
        "deviceId": deviceId,
        "deviceName": deviceName,
        "deviceManufacturer": deviceManufacturer,
        "deviceProduct": deviceProduct,
        "deviceSerialNumber": deviceSerialNumber,
      }
    };

    final headers = {
      "authtoken": Env.token,
    };

    return _client.post<Map<String, dynamic>>(
      Env.baseUrl,
      data: payload,
      headers: headers,
    );
  }

  // Search Auto Complete api
  Future<Response<Map<String, dynamic>>> autocomplete({
    required String inputText,
    required String visitorToken,
    List<String>? searchType,
    int limit = 10,
  }) {
    final payload = {
      "action": Constants.searchAutocomplete,
      "searchAutoComplete": {
        "inputText": inputText,
        "searchType": searchType ??
            [
              "byCity",
              "byState",
              "byCountry",
              "byRandom",
              "byPropertyName",
            ],
        "limit": limit,
      }
    };

    final headers = {
      "authtoken": Env.token,
      "visitortoken": visitorToken,
    };

    return _client.post<Map<String, dynamic>>(
      Env.baseUrl,
      data: payload,
      headers: headers,
    );
  }


  //  Property List api
  Future<Response<Map<String, dynamic>>> getPropertyList({
    required String visitorToken,
    int limit = 10,
    String entityType = "Any",
    required String searchType,
    String? country,
    String? state,
    String? city,
    String currency = "INR",
  }) {
    final searchTypeInfo = <String, dynamic>{};
    if (country != null) searchTypeInfo["country"] = country;
    if (state != null) searchTypeInfo["state"] = state;
    if (city != null) searchTypeInfo["city"] = city;

    final payload = {
      "action": Constants.popularStay,
      "popularStay": {
        "limit": limit,
        "entityType": entityType,
        "filter": {
          "searchType": searchType,
          "searchTypeInfo": searchTypeInfo,
        },
        "currency": currency,
      }
    };

    final headers = {
      "authtoken": Env.token,
      "visitortoken": visitorToken,
    };

    return _client.post<Map<String, dynamic>>(
      Env.baseUrl,
      data: payload,
      headers: headers,
    );
  }

  // GET SEARCH RESULT (List of Hotels with filters)
  Future<Response<Map<String, dynamic>>> getSearchResult({
    required String visitorToken,
    required String checkIn,
    required String checkOut,
    int rooms = 1,
    int adults = 2,
    int children = 0,

    String searchType = "hotelIdSearch",
    required List<String> searchQuery,

    List<String>? accommodation,
    List<String>? arrayOfExcludedSearchType,
    String highPrice = "3000000",
    String lowPrice = "0",
    int limit = 5,
    List<dynamic> preloaderList = const [],
    String currency = "INR",
    int rid = 0,
  }) {
    final payload = {
      "action": Constants.searchResult,
      "getSearchResultListOfHotels": {
        "searchCriteria": {
          "checkIn": checkIn,
          "checkOut": checkOut,
          "rooms": rooms,
          "adults": adults,
          "children": children,
          "searchType": searchType,
          "searchQuery": searchQuery,
          "accommodation": accommodation ??
              [
                "all",
                "hotel",
              ],
          "arrayOfExcludedSearchType": arrayOfExcludedSearchType ?? [],
          "highPrice": highPrice,
          "lowPrice": lowPrice,
          "limit": limit,
          "preloaderList": preloaderList,
          "currency": currency,
          "rid": rid,
        }
      }
    };

    final headers = {
      "authtoken": Env.token,
      "visitortoken": visitorToken,
    };

    return _client.post<Map<String, dynamic>>(
      Env.baseUrl,
      data: payload,
      headers: headers,
    );
  }

  //  GET CURRENCY LIST
  Future<Response<Map<String, dynamic>>> getCurrencyList({
    required String visitorToken,
    String baseCode = "INR",
  }) {
    final payload = {
      "action": Constants.currencyList,
      "getCurrencyList": {
        "baseCode": baseCode,
      }
    };

    final headers = {
      "authtoken": Env.token,
      "visitortoken": visitorToken,
    };

    return _client.post<Map<String, dynamic>>(
      Env.baseUrl,
      data: payload,
      headers: headers,
    );
  }

  //  APP SETTINGS
  Future<Response<Map<String, dynamic>>> getAppSettings() {


    final headers = {
      "authtoken": Env.token,
    };

    return _client.post<Map<String, dynamic>>(
      Env.baseUrl + Env.appSettings,
      // data: payload,
      headers: headers,
    );
  }
}