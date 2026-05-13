import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_localizations.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggle() {
    state = state.languageCode == 'en' ? const Locale('ru') : const Locale('en');
  }
}

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  return AppLocalizations(ref.watch(localeProvider));
});
