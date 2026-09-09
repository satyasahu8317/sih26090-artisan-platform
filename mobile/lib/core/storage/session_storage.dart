import 'package:hive_flutter/hive_flutter.dart';

class SessionStorage {
  SessionStorage._();

  static const String _boxName = 'session';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _roleKey = 'role';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> saveSession({
    required String role,
  }) async {
    await _box.put(_isLoggedInKey, true);
    await _box.put(_roleKey, role);
  }

  static bool get isLoggedIn =>
      _box.get(_isLoggedInKey, defaultValue: false) == true;

  static String? get role {
    final value = _box.get(_roleKey);
    return value is String ? value : null;
  }

  static Future<void> clearSession() async {
    await _box.clear();
  }
}