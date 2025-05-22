import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:podcat/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadLanguage(
      LoadLanguage event, Emitter<LanguageState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(StorageConstants.language) ?? 'vi';
      emit(state.copyWith(locale: Locale(languageCode)));
    } catch (_) {
      emit(state);
    }
  }

  Future<void> _onChangeLanguage(
      ChangeLanguage event, Emitter<LanguageState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          StorageConstants.language, event.locale.languageCode);
      emit(state.copyWith(locale: event.locale));
    } catch (_) {
      emit(state);
    }
  }
}
