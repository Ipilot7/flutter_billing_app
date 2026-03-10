import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billing_app/core/data/hive_database.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('ru')) {
    _loadLocale();
  }

  void _loadLocale() {
    final savedLocale = HiveDatabase.settingsBox.get('locale');
    if (savedLocale != null) {
      emit(Locale(savedLocale));
    }
  }

  Future<void> setLocale(Locale locale) async {
    await HiveDatabase.settingsBox.put('locale', locale.languageCode);
    emit(locale);
  }
}
