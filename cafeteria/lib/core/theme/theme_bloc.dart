import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';

  ThemeBloc(this._prefs) : super(_loadTheme(_prefs)) {
    on<ToggleThemeEvent>((event, emit) async {
      final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      await _prefs.setString(_themeKey, newMode.name);
      emit(newMode);
    });

    on<SetThemeEvent>((event, emit) async {
      await _prefs.setString(_themeKey, event.mode.name);
      emit(event.mode);
    });
  }

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme == null) return ThemeMode.light;
    return ThemeMode.values.firstWhere(
      (e) => e.name == savedTheme,
      orElse: () => ThemeMode.light,
    );
  }
}