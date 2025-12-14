import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:aiSeaSafe/services/client/network_client.dart';
import 'package:aiSeaSafe/utils/helper/log_helper.dart';


// import '../../../constants/global_variable.dart';
//     show MultipartFile, ResponseType, Response, DioException;

export 'exception.dart';
export 'header_builder.dart';
export 'result.dart';

enum MethodType {
  post('POST'),
  get('GET'),
  delete('DELETE'),
  put('PUT'),
  patch('PATCH');

  final String value;

  const MethodType(this.value);
}

enum Flavor { develop, qa, staging, production, local }

enum MileStone { v1, v2, v3, v4, v5 }

class NetworkClient {
  final Dio _dio;

  NetworkClient()
    : _dio = Dio(BaseOptions(baseUrl: ''))
        ..interceptors.addAll([
          LogInterceptor(
            logPrint: (object) {
              LoggerHelper.logInfo('Request: ${object.runtimeType} : $object');
            },
          ),
          AuthorizationInterceptor(responseType: ResponseType.json),
        ]);

  NetworkClient.fromBaseUrl(
    String baseUrl, {
    ResponseType responseType = ResponseType.json,
    Iterable<Interceptor> interceptors = const [],
  }) : _dio = Dio(BaseOptions(baseUrl: baseUrl))
         ..interceptors.addAll(interceptors);

  Future<Response<dynamic>> request({
    required String path,
    required MethodType method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    log('====> access token : ${"preferences.token"}');
    try {
      return await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method.value),
      );
    } on DioException catch (e) {
      String message = e.message ?? e.error.toString();

      Map<String, dynamic> data = e.response?.data ?? {};

      if (data.containsKey('message')) {
        message = data['message'];
      }
      throw NetworkClientException(message: message, response: e.response);
    }
  }
}

class AuthorizationInterceptor extends Interceptor {
  final ResponseType responseType;

  AuthorizationInterceptor({this.responseType = ResponseType.json});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    HeaderBuilder headerBuilder = HeaderBuilder.builder().setContentType(
      'application/x-www-form-urlencoded',
    );
    String? accessToken = "preferences.token";

    if (accessToken != null) {
      headerBuilder.setBearerToken(accessToken);
    }

    options.headers = headerBuilder.build();
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    switch (err.response?.statusCode) {
      case 400:
        break;
      case 401:
        break;
      case 403:
        break;
      case 500:
        break;
      default:
    }
    handler.next(err);
  }
}
