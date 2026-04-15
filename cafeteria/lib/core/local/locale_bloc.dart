import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'locale_event.dart';

class LocaleBloc extends Bloc<LocaleEvent, Locale> {
  LocaleBloc() : super(const Locale('en')) {
    on<SetLocaleEvent>((event, emit) {
      emit(event.locale);
    });

    on<ToggleLocaleEvent>((event, emit) {
      emit(
        state.languageCode == 'en' ? const Locale('ar') : const Locale('en'),
      );
    });
  }
}
