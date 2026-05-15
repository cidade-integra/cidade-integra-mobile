import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _fcmTokenKey = 'fcm_token';
  static const _lastUidKey = 'last_uid';

  static Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  static Future<String?> readFcmToken() async {
    return _storage.read(key: _fcmTokenKey);
  }

  static Future<void> saveLastUid(String uid) async {
    await _storage.write(key: _lastUidKey, value: uid);
  }

  static Future<String?> readLastUid() async {
    return _storage.read(key: _lastUidKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
