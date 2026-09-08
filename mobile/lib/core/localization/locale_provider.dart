import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_storage.dart';

final localeProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(),
);

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en')) {
    _restore();
  }

  static const supportedLanguageCodes = {'en', 'hi', 'mr', 'bn', 'gu', 'ta', 'te'};

  Future<void> _restore() async {
    final saved = await LocaleStorage.read();
    if (saved != null && supportedLanguageCodes.contains(saved)) {
      state = Locale(saved);
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguageCodes.contains(languageCode)) return;
    state = Locale(languageCode);
    await LocaleStorage.write(languageCode);
  }
}
