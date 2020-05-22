import 'package:flutter/material.dart';

class OriginTheme extends ChangeNotifier {
  Color _primaryColor;
  Color _primaryColorLight;
  Color _primaryColorDark;
  Color _accentColor;
  Color _textColor;

  OriginTheme({
    Color primaryColor,
    Color primaryColorLight,
    Color primaryColorDark,
    Color accentColor,
    Color textColor,
  }) {
    this._primaryColor = primaryColor;
    this._primaryColorLight = primaryColorLight;
    this._primaryColorDark = primaryColorDark;
    this._accentColor = accentColor;
    this._textColor = textColor;
  }

  get primaryColor => this._primaryColor;
  get primaryColorLight => this._primaryColorLight;
  get primaryColorDark => this._primaryColorDark;
  get accentColor => this._accentColor;
  get textColor => this._textColor;

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

  set textColor(Color color) {
    this._textColor = color;
    notifyListeners();
  }
}
