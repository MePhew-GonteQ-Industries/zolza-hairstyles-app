import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyRefreshToken = 'refreshToken';
  static setRefreshToken(String refreshToken) async =>
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
  static getRefreshToken() async => await _storage.read(key: _keyRefreshToken);
}
