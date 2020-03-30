import 'package:flutter/material.dart';
import 'package:skeduler/models/class.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:skeduler/models/person.dart';
import 'package:skeduler/models/timetable.dart';

class Group {
  /// properties
  String _name;
  String _description;
  Color _color;

  List<Person> _people;
  List<Class> _classes;
  List<Timetable> _timetables;

  /// constructor
  Group({
    String name = '',
    String description = '',
    Color color = defaultColor,
  }) {
    _name = name;
    _description = description;
    _color = color;
  }

  /// getter methods
  String get name => _name;
  String get description => _description;
  Color get color => _color;
  List<Person> get people => _people;
  List<Class> get classes => _classes;
  List<Timetable> get timetables => _timetables;
}
