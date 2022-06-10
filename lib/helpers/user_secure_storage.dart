import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyRefreshToken = 'refreshToken';
  static const _keyfcmToken = 'fcmToken';
  static setRefreshToken(String refreshToken) async =>
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
  static getRefreshToken() async => await _storage.read(key: _keyRefreshToken);
  static setFCMToken(String? fcmToken) async => await _storage.write(key: _keyfcmToken, value: fcmToken);
  static getFCMToken() async => await _storage.read(key: _keyfcmToken);
}
