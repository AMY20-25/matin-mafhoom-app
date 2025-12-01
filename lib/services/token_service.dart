import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _key = "access_token";

  /// ذخیره توکن
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  /// خواندن توکن
  static Future<String?> getToken() async {
    return await _storage.read(key: _key);
  }

  /// حذف توکن (برای لاگ‌اوت)
  static Future<void> clearToken() async {
    await _storage.delete(key: _key);
  }
}

