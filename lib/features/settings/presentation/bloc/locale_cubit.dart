import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billing_app/core/data/app_database.dart';

class LocaleCubit extends Cubit<Locale> {
  final AppDatabase _db;

  LocaleCubit(this._db) : super(const Locale('ru')) {
    _loadLocale();
  }

  void _loadLocale() async {
    final savedLocale = await _db.getSetting('locale');
    if (savedLocale != null) {
      emit(Locale(savedLocale));
    }
  }

  Future<void> setLocale(Locale locale) async {
    await _db.saveSetting('locale', locale.languageCode);
    emit(locale);
  }
}
