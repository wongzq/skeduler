import 'package:flutter/material.dart';

enum DrawerEnum {
  dashboard,
  group,
  members,
  classes,
  timetable,
  mySchedule,
  settings,
  logout,
}

class DrawerEnumHistory extends ChangeNotifier {
  /// properties
  List<DrawerEnum> _history;

  /// constructors
  DrawerEnumHistory({history}) {
    this._history = history == null ? [] : history;
  }

  /// getter methods
  get current => _history.last;
  get history => _history;

  /// modifying methods
  void add(DrawerEnum drawerEnum) {
    this._history.add(drawerEnum);
    notifyListeners();
  }

  void pop() {
    if (this._history.isNotEmpty) {
      this._history.removeLast();
      notifyListeners();
    }
  }
}
