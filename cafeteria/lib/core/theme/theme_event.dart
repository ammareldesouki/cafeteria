part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class SetThemeEvent extends ThemeEvent {
  final ThemeMode mode;
  SetThemeEvent(this.mode);
}