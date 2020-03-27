import 'package:flutter/material.dart';

class NativeTheme extends ChangeNotifier {
  Color _primaryColor;
  Color _primaryColorLight;
  Color _primaryColorDark;
  Color _accentColor;

  NativeTheme({
    Color primaryColor,
    Color primaryColorLight,
    Color primaryColorDark,
    Color accentColor,
  }) {
    _primaryColor = primaryColor;
    _primaryColorLight = primaryColorLight;
    _primaryColorDark = primaryColorDark;
    _accentColor = accentColor;
  }

  get primaryColor => _primaryColor;
  get primaryColorLight => _primaryColorLight;
  get primaryColorDark => _primaryColorDark;
  get accentColor => _accentColor;

  set primaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  set primaryColorLight(Color color) {
    _primaryColorLight = color;
    notifyListeners();
  }

  set primaryColorDark(Color color) {
    _primaryColorDark = color;
    notifyListeners();
  }

  set accentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }
}
