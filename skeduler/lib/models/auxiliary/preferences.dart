import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';

const Map<Language, Map<String, Map<String, String>>> translations = {
  Language.eng: {
    'Settings': {
      'Name': 'Name',
      'Dark mode': 'Dark mode',
      'Theme color': 'Theme color',
      'Language': 'Language',
      'Timetable Display': 'Timetable Display',
    },
  },
  Language.chi: {
    'Settings': {
      'Name': '名字',
      'Dark mode': '暗模式',
      'Theme color': '主题色',
      'Language': '语言',
      'Timetable Display': '时间表显示',
    },
  },
};

class Preferences extends ChangeNotifier {
  // properties
  SharedPreferences _value;

  // constructor
  Preferences(this._value);

  // getter methods
  Language get language => Language.values[this._value.getInt('language') ?? 0];
  DisplaySize get displaySize =>
      DisplaySize.values[this._value.getInt('displaySize') ?? 1];

  // setter methods
  Future<bool> setLanguage(Language language) =>
      this._value.setInt('language', language.index);
  Future<bool> setDisplaySize(DisplaySize displaySize) =>
      this._value.setInt('displaySize', displaySize.index);
}
