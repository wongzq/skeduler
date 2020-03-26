import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  bool dark;
  String color;
  Brightness _brightness;
  MaterialColor _primarySwatch;
  MaterialAccentColor _accentColor;

  ThemeChanger({this.dark = false, this.color = ''}) {
    setTheme(dark: dark, color: color);
  }

  get brightness => _brightness;
  get primarySwatch => _primarySwatch;
  get accentColor => _accentColor;

  setTheme({bool dark = false, String color = ''}) {
    // set brightness
    if (dark == true) {
      _brightness = Brightness.dark;
    } else {
      _brightness = Brightness.light;
    }

    // set primarySwatch and accentColor
    if (color == 'pink') {
      _primarySwatch = Colors.pink;
      _accentColor = Colors.pinkAccent;
    } else if (color == 'red') {
      _primarySwatch = Colors.red;
      _accentColor = Colors.redAccent;
    } else if (color == 'deepOrange') {
      _primarySwatch = Colors.deepOrange;
      _accentColor = Colors.deepOrangeAccent;
    } else if (color == 'orange') {
      _primarySwatch = Colors.orange;
      _accentColor = Colors.orangeAccent;
    } else if (color == 'amber') {
      _primarySwatch = Colors.amber;
      _accentColor = Colors.amberAccent;
    } else if (color == 'yellow') {
      _primarySwatch = Colors.yellow;
      _accentColor = Colors.yellowAccent;
    } else if (color == 'lime') {
      _primarySwatch = Colors.lime;
      _accentColor = Colors.limeAccent;
    } else if (color == 'lightGreen') {
      _primarySwatch = Colors.lightGreen;
      _accentColor = Colors.lightGreenAccent;
    } else if (color == 'green') {
      _primarySwatch = Colors.green;
      _accentColor = Colors.greenAccent;
    } else if (color == 'teal') {
      _primarySwatch = Colors.teal;
      _accentColor = Colors.tealAccent;
    } else if (color == 'cyan') {
      _primarySwatch = Colors.cyan;
      _accentColor = Colors.cyanAccent;
    } else if (color == 'lightBlue') {
      _primarySwatch = Colors.lightBlue;
      _accentColor = Colors.lightBlueAccent;
    } else if (color == 'blue') {
      _primarySwatch = Colors.blue;
      _accentColor = Colors.blueAccent;
    } else if (color == 'indigo') {
      _primarySwatch = Colors.indigo;
      _accentColor = Colors.indigoAccent;
    } else if (color == 'deepPurple') {
      _primarySwatch = Colors.deepPurple;
      _accentColor = Colors.deepPurpleAccent;
    } else if (color == 'purple') {
      _primarySwatch = Colors.purple;
      _accentColor = Colors.purpleAccent;
    } else {
      _primarySwatch = Colors.teal;
      _accentColor = Colors.tealAccent;
    }

    notifyListeners();
  }
}
