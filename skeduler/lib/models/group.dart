import 'package:skeduler/models/class.dart';
import 'package:skeduler/models/color_shade.dart';
import 'package:skeduler/models/person.dart';
import 'package:skeduler/models/timetable.dart';

class Group {
  /// properties
  String _uid;

  String _name;
  String _description;
  ColorShade _colorShade;
  String _ownerEmail;
  String _ownerName;

  List<Person> _people = [];
  List<Class> _classes = [];
  List<Timetable> _timetables = [];

  /// constructor
  Group(
    String uid, {
    String name = '',
    String description = '',
    ColorShade colorShade,
    String ownerEmail = '',
    String ownerName = '',
  }) {
    _uid = uid;
    _name = name;
    _description = description;
    _colorShade = colorShade;
    _ownerEmail = ownerEmail;
    _ownerName = ownerName;
  }

  /// getter methods
  String get name => _name;
  String get description => _description;
  ColorShade get colorShade => _colorShade;
  String get ownerEmail => _ownerEmail;
  String get ownerName => _ownerName;
  int get numOfMembers => 1;

  List<Person> get people => _people;
  List<Class> get classes => _classes;
  List<Timetable> get timetables => _timetables;
}
