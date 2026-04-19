import 'package:aisend/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'schemas/api_exception.dart';


class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: Duration(milliseconds: AppConfig.requestTimeout.inMilliseconds),
      receiveTimeout: Duration(milliseconds: AppConfig.requestTimeout.inMilliseconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Api-Key': AppConfig.apiKey,
      },
    ));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));
  }

  Future<dynamic> get(String url) => getUri(Uri.parse(url));

  Future<dynamic> getUri(Uri uri) async {
    try {
      final response = await _dio.getUri(uri);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> post(String url, {required Map<String, dynamic> body}) async {
    try {
      final response = await _dio.post(url, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> patch(String url, {required Map<String, dynamic> body}) async {
    try {
      final response = await _dio.patch(url, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> put(String url, {required Map<String, dynamic> body}) async {
    try {
      final response = await _dio.put(url, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // Unwraps ApiResponse<T> envelope. Falls back to raw data for non-wrapped responses.
  dynamic _handleResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('success')) {
        if (data['success'] == true) return data['data'];
        final msg = data['message'] as String? ?? 'Erro desconhecido';
        throw ApiException(message: msg, statusCode: response.statusCode ?? 0);
      }
      return data;
    }
    throw ApiException(
      message: _extractMessage(response.data) ?? 'HTTP ${response.statusCode}',
      statusCode: response.statusCode ?? 0,
    );
  }

  // Extracts the human-readable message from ApiResponse.Fail or legacy error bodies.
  ApiException _mapError(DioException e) {
    final res = e.response;
    if (res != null) {
      final msg = _extractMessage(res.data) ?? 'HTTP ${res.statusCode}';
      return ApiException(message: msg, statusCode: res.statusCode ?? 0);
    }
    return ApiException(message: 'Erro de rede: ${e.message}', statusCode: 0);
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }
}
