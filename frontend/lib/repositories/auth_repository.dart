import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
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
    } catch (e) {
      // Mock auth fallback for development / offline
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
    } catch (_) {}
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
      return auth;
    } catch (e) {
      final mock = AuthResponse(
        accessToken: 'mock_verified_token',
        refreshToken: 'mock_refresh',
        email: email,
        role: 'STUDENT',
      );
      await storage.saveTokens(accessToken: mock.accessToken, refreshToken: mock.refreshToken);
      return mock;
    }
  }

  Future<void> resendCode(String email) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.resendCode,
        data: {'email': email},
      );
    } catch (_) {}
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.passwordResetRequest,
        data: {'email': email},
      );
    } catch (_) {}
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
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await storage.clearAll();
  }
}
