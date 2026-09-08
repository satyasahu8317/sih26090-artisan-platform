import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleStorage {
  LocaleStorage._();

  static const _key = 'app_locale';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> read() => _storage.read(key: _key);

  static Future<void> write(String languageCode) =>
      _storage.write(key: _key, value: languageCode);
}
