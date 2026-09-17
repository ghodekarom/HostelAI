import 'package:dio/dio.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({String? baseUrl}) {
    // Read from environment if available, fallback to localhost
    const envBaseUrl = String.fromEnvironment(
      'HFCMS_API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1',
    );

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? envBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logging & interceptors will be attached here
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }
}
