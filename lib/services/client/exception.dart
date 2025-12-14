import 'package:dio/dio.dart';

class NetworkClientException implements Exception {
  final String message;
  final Response<dynamic>? response;

  const NetworkClientException({required this.message, this.response});

  @override
  String toString() {
    return 'NetworkClientException(message: $message, response: ${response.toString()})';
  }
}
