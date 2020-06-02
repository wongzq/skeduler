import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';

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
  Future<bool> setLanguage(Language language) {
    return this._value.setInt('language', language.index).then((value) {
      notifyListeners();
      return value;
    });
  }

  Future<bool> setDisplaySize(DisplaySize displaySize) {
    return this._value.setInt('displaySize', displaySize.index).then((value) {
      notifyListeners();
      return value;
    });
  }
}

const Map<Language, Map<String, String>> translationGeneral = {
  Language.eng: {
    'Cance;': 'CANCEL',
    'Confirm': 'CONFIRM',
    'Ok': 'OK',
  },
  Language.chi: {
    'Cancel': '取消',
    'Confirm': '确认',
    'Ok': '确认',
  },
};

const Map<Language, Map<DrawerEnum, Map<String, String>>> translation = {
  Language.eng: {
    DrawerEnum.settings: {
      'title': 'Settings',
      'Name': 'Name',
      'Dark mode': 'Dark mode',
      'Theme color': 'Theme color',
      'Language': 'Language',
      'Timetable Display': 'Timetable Display',
    },
  },
  Language.chi: {
    DrawerEnum.settings: {
      'title': '设定',
      'Name': '名字',
      'Dark mode': '黑暗模式',
      'Theme color': '主题颜色',
      'Language': '语言',
      'Timetable Display': '时间表显示',
    },
  },
};
