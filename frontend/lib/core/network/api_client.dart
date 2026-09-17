import 'package:dio/dio.dart';
import 'api_exception.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService? storage;

  ApiClient({
    String? baseUrl,
    String? userId,
    String? technicianId,
    this.storage,
  }) {
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
        onRequest: (options, handler) async {
          if (storage != null && !options.path.contains('/auth/')) {
            final token = await storage!.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Automatic token refresh on 401 Unauthorized for non-auth endpoints
          if (e.response?.statusCode == 401 &&
              storage != null &&
              !e.requestOptions.path.contains('/auth/')) {
            try {
              final refreshToken = await storage!.getRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: dio.options.baseUrl,
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                  ),
                );

                final res = await refreshDio.post(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );

                if (res.statusCode == 200 && res.data['data'] != null) {
                  final data = res.data['data'] as Map<String, dynamic>;
                  final newAccess = data['accessToken']?.toString();
                  final newRefresh = data['refreshToken']?.toString();

                  if (newAccess != null && newRefresh != null) {
                    await storage!.saveTokens(
                      accessToken: newAccess,
                      refreshToken: newRefresh,
                    );

                    final requestOptions = e.requestOptions;
                    requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                    final retryResponse = await dio.fetch(requestOptions);
                    return handler.resolve(retryResponse);
                  }
                }
              }
            } catch (_) {
              await storage!.clearAll();
            }
          }

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
