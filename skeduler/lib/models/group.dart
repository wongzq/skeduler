import 'package:flutter/material.dart';
import 'package:skeduler/models/class.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:skeduler/models/person.dart';
import 'package:skeduler/models/timetable.dart';
import 'package:skeduler/shared/functions.dart';

class Group {
  /// properties
  String _name;
  String _description;
  String _colorStr;
  int _colorInt;
  String _ownerEmail;
  String _ownerName;

  List<Person> _people = [];
  List<Class> _classes = [];
  List<Timetable> _timetables = [];

  /// constructor
  Group({
    String name = '',
    String description = '',
    String colorStr = '',
    int colorInt = 0,
    String ownerEmail = '',
    String ownerName = '',
  }) {
    _name = name;
    _description = description;
    _colorStr = colorStr;
    _colorInt = colorInt;
    _ownerEmail = ownerEmail;
    _ownerName = ownerName;
  }

  /// getter methods
  String get name => _name;
  String get description => _description;
  String get colorStr => _colorStr;
  int get colorInt => _colorInt;
  Color get color => getColorFromStrInt(_colorStr, _colorInt) ?? defaultColor;
  String get ownerEmail => _ownerEmail;
  String get ownerName => _ownerName;
  int get numOfMembers => 1;

  List<Person> get people => _people;
  List<Class> get classes => _classes;
  List<Timetable> get timetables => _timetables;
}
