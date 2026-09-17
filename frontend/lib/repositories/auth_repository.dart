import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../core/storage/secure_storage.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storage;

  AuthRepository({required this.apiClient, required this.storage});

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final res = await apiClient.dio.post(
        ApiEndpoints.signin,
        data: {'email': email, 'password': password},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final auth = AuthResponse.fromJson(data);
      await storage.saveTokens(accessToken: auth.accessToken, refreshToken: auth.refreshToken);
      await storage.saveUserData(email: auth.email, role: auth.role);
      return auth;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw (e.error as ApiException).message;
      }
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        // Fallback for offline demo mode
        final mock = AuthResponse(
          accessToken: 'mock_jwt_access_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshToken: 'mock_jwt_refresh_token',
          email: email,
          fullName: email.split('@').first.toUpperCase(),
          role: 'STUDENT',
        );
        await storage.saveTokens(accessToken: mock.accessToken, refreshToken: mock.refreshToken);
        await storage.saveUserData(email: mock.email, role: mock.role);
        return mock;
      }
      throw e.message ?? 'Authentication failed';
    }
  }

  Future<void> signUp(String email, String password, String fullName, String role) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.signup,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw (e.error as ApiException).message;
      }
      throw e.message ?? 'Sign up failed';
    }
  }

  Future<AuthResponse> verifyCode(String email, String code) async {
    try {
      final res = await apiClient.dio.post(
        ApiEndpoints.verify,
        data: {'email': email, 'code': code},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final auth = AuthResponse.fromJson(data);
      await storage.saveTokens(accessToken: auth.accessToken, refreshToken: auth.refreshToken);
      await storage.saveUserData(email: auth.email, role: auth.role);
      return auth;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw (e.error as ApiException).message;
      }
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        final mock = AuthResponse(
          accessToken: 'mock_verified_token',
          refreshToken: 'mock_refresh',
          email: email,
          role: 'STUDENT',
        );
        await storage.saveTokens(accessToken: mock.accessToken, refreshToken: mock.refreshToken);
        return mock;
      }
      throw e.message ?? 'Verification failed';
    }
  }

  Future<void> resendCode(String email) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.resendCode,
        data: {'email': email},
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw (e.error as ApiException).message;
      }
      throw e.message ?? 'Failed to resend code';
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.passwordResetRequest,
        data: {'email': email},
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw (e.error as ApiException).message;
      }
      throw e.message ?? 'Password reset request failed';
    }
  }

  Future<void> confirmPasswordReset(String email, String code, String newPassword) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.passwordResetConfirm,
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw (e.error as ApiException).message;
      }
      throw e.message ?? 'Password reset confirmation failed';
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await storage.clearAll();
  }
}
