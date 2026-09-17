import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'hfcms_access_token';
  static const _keyRefreshToken = 'hfcms_refresh_token';
  static const _keyUserRole = 'hfcms_user_role';
  static const _keyUserEmail = 'hfcms_user_email';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUserData({required String email, required String role}) async {
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<String?> getUserRole() async {
    return _storage.read(key: _keyUserRole);
  }

  Future<String?> getUserEmail() async {
    return _storage.read(key: _keyUserEmail);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
