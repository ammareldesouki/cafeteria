part of 'locale_bloc.dart';

abstract class LocaleEvent {}

class SetLocaleEvent extends LocaleEvent {
  final Locale locale;

  SetLocaleEvent(this.locale);
}

class ToggleLocaleEvent extends LocaleEvent {}
