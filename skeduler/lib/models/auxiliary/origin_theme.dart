import 'package:flutter/material.dart';

class OriginTheme extends ChangeNotifier {
  Color _primaryColor;
  Color _primaryColorLight;
  Color _primaryColorDark;
  Color _accentColor;

  OriginTheme({
    Color primaryColor,
    Color primaryColorLight,
    Color primaryColorDark,
    Color accentColor,
  }) {
    this._primaryColor = primaryColor;
    this._primaryColorLight = primaryColorLight;
    this._primaryColorDark = primaryColorDark;
    this._accentColor = accentColor;
  }

  get primaryColor => this._primaryColor;
  get primaryColorLight => this._primaryColorLight;
  get primaryColorDark => this._primaryColorDark;
  get accentColor => this._accentColor;

  set primaryColor(Color color) {
    this._primaryColor = color;
    notifyListeners();
  }

  set primaryColorLight(Color color) {
    this._primaryColorLight = color;
    notifyListeners();
  }

  set primaryColorDark(Color color) {
    this._primaryColorDark = color;
    notifyListeners();
  }

  set accentColor(Color color) {
    this._accentColor = color;
    notifyListeners();
  }
}
