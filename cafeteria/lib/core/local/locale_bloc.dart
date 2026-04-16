import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_event.dart';

class LocaleBloc extends Bloc<LocaleEvent, Locale> {
  final SharedPreferences _prefs;
  static const String _localeKey = 'locale_code';

  LocaleBloc(this._prefs) : super(_loadLocale(_prefs)) {
    on<SetLocaleEvent>((event, emit) async {
      await _prefs.setString(_localeKey, event.locale.languageCode);
      emit(event.locale);
    });

    on<ToggleLocaleEvent>((event, emit) async {
      final newLocale = state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
      await _prefs.setString(_localeKey, newLocale.languageCode);
      emit(newLocale);
    });
  }

  static Locale _loadLocale(SharedPreferences prefs) {
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale == null) return const Locale('en');
    return Locale(savedLocale);
  }
}
