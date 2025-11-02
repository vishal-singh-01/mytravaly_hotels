import 'package:dio/dio.dart';
import '../env.dart';


class AuthHeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'Authorization': 'Bearer ${Env.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });
    super.onRequest(options, handler);
  }
}