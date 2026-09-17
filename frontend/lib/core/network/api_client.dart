import 'package:dio/dio.dart';
import 'api_exception.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({String? baseUrl, String? userId, String? technicianId}) {
    const envBaseUrl = String.fromEnvironment(
      'HFCMS_API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1',
    );

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (userId != null) {
      headers['X-User-Id'] = userId;
    }
    if (technicianId != null) {
      headers['X-Technician-Id'] = technicianId;
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? envBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: headers,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          if (e.response != null && e.response?.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            final message = data['message']?.toString() ?? e.message ?? 'Unknown error';
            final error = data['error']?.toString();
            Map<String, String>? fieldErrors;

            if (data['fieldErrors'] is List) {
              fieldErrors = {};
              for (final item in data['fieldErrors'] as List) {
                if (item is Map) {
                  final field = item['field']?.toString() ?? '';
                  final msg = item['message']?.toString() ?? '';
                  if (field.isNotEmpty) fieldErrors[field] = msg;
                }
              }
            }

            final apiEx = ApiException(
              statusCode: e.response?.statusCode,
              message: message,
              error: error,
              fieldErrors: fieldErrors,
            );
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                error: apiEx,
                message: apiEx.message,
              ),
            );
          }
          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
      ),
    );
  }
}
