import 'package:dio/dio.dart';

abstract class HttpService {
  Future<Response> request({
    required String url,
    required String method,
    required Map<String, dynamic> headers,
    dynamic data,
  });
}

class DioHttpService implements HttpService {
  final Dio _dio = Dio();

  @override
  Future<Response> request({
    required String url,
    required String method,
    required Map<String, dynamic> headers,
    dynamic data,
  }) {
    return _dio.request(
      url,
      data: data,
      options: Options(
        method: method,
        headers: headers,
        validateStatus: (status) => true, // Capture all status codes
      ),
    );
  }
}
