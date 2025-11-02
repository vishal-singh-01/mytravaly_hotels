class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  AppException(this.message, {this.statusCode, this.data});


  @override
  String toString() => 'AppException($statusCode): $message';
}