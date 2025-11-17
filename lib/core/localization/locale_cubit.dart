import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  static const String _prefsKey = 'app_locale_code';

  LocaleCubit() : super(const LocaleState(locale: Locale('ar', 'EG')));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null) return;
    switch (code) {
      case 'ar':
        emit(const LocaleState(locale: Locale('ar', 'EG')));
        break;
      case 'en':
        emit(const LocaleState(locale: Locale('en', 'US')));
        break;
    }
  }

  Future<void> setArabic() async {
    emit(const LocaleState(locale: Locale('ar', 'EG')));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, 'ar');
  }

  Future<void> setEnglish() async {
    emit(const LocaleState(locale: Locale('en', 'US')));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, 'en');
  }

  Future<void> toggle() async {
    if (state.locale.languageCode == 'ar') {
      await setEnglish();
    } else {
      await setArabic();
    }
  }
}


