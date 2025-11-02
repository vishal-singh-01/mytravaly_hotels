import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../env.dart';
import 'exceptions.dart';
import 'interceptors.dart';

class DioClient {
  final Dio _dio;

  DioClient._(this._dio);

  factory DioClient.create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "",
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    // Attach interceptors
    dio.interceptors.addAll([
      AuthHeaderInterceptor(),
      _FullApiLogger(), // 👈 custom logging interceptor
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
      ),
    ]);

    return DioClient._(dio);
  }

  /// GET
  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? query,
        Map<String, String>? headers,
      }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: query,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  /// POST
  Future<Response<T>> post<T>(
      String path, {
        Map<String, dynamic>? data,
        Map<String, dynamic>? query,
        Map<String, String>? headers,
      }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  AppException _wrap(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final msg = data is Map && data['message'] is String
        ? data['message'] as String
        : e.message ?? 'Unexpected error';
    return AppException(msg, statusCode: status, data: data);
  }
}

/// --------------------------------------------------------------------------
/// CUSTOM LOGGING INTERCEPTOR
/// Logs URL, headers, body, and response neatly.
/// --------------------------------------------------------------------------
class _FullApiLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('➡️API REQUEST ===  [${options.method}] ${options.baseUrl}${options.path}');
    if (options.queryParameters.isNotEmpty) {
      print('🔹 Query: ${options.queryParameters}');
    }
    if (options.headers.isNotEmpty) {
      print('🧾 Headers: ${options.headers}');
    }
    if (options.data != null) {
      print('📦 Body: ${_prettyJson(options.data)}');
    }
    print('========================================================\n');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('\n==================== ✅ API RESPONSE ====================');
    print('⬅️API RESPONSE ===  [${response.statusCode}] ${response.requestOptions.path}');
    print('📦 Data: ${_prettyJson(response.data)}');
    print('========================================================\n');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('\n==================== ❌ API ERROR ====================');
    print('❗ [${err.response?.statusCode}] ${err.requestOptions.path}');
    print('🔹 Message: ${err.message}');
    if (err.response?.data != null) {
      print('📦 Error Data: ${_prettyJson(err.response?.data)}');
    }
    print('====================================================\n');
    super.onError(err, handler);
  }

  String _prettyJson(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}


// class DioClient {
//   final Dio _dio;
//
//   DioClient._(this._dio);
//
//   factory DioClient.create() {
//     final dio = Dio(
//       BaseOptions(
//         baseUrl: Env.baseUrl,
//         connectTimeout: const Duration(seconds: 15),
//         receiveTimeout: const Duration(seconds: 15),
//       ),
//     );
//
//     dio.interceptors.addAll([
//       AuthHeaderInterceptor(),
//       PrettyDioLogger(
//         requestHeader: true,
//         requestBody: true,
//         responseBody: false,
//         responseHeader: false,
//         compact: true,
//       ),
//     ]);
//
//     return DioClient._(dio);
//   }
//
//   ///  GET
//   Future<Response<T>> get<T>(
//       String path, {
//         Map<String, dynamic>? query,
//         Map<String, String>? headers,
//       }) async {
//     try {
//       return await _dio.get<T>(
//         path,
//         queryParameters: query,
//         options: Options(headers: headers),
//       );
//     } on DioException catch (e) {
//       throw _wrap(e);
//     }
//   }
//
//   ///  POST
//   Future<Response<T>> post<T>(
//       String path, {
//         Map<String, dynamic>? data,
//         Map<String, dynamic>? query,
//         Map<String, String>? headers,
//       }) async {
//     try {
//       return await _dio.post<T>(
//         path,
//         data: data,
//         queryParameters: query,
//         options: Options(headers: headers),
//       );
//     } on DioException catch (e) {
//       throw _wrap(e);
//     }
//   }
//
//   AppException _wrap(DioException e) {
//     final status = e.response?.statusCode;
//     final data = e.response?.data;
//     final msg = data is Map && data['message'] is String
//         ? data['message'] as String
//         : e.message ?? 'Unexpected error';
//     return AppException(msg, statusCode: status, data: data);
//   }
// }

