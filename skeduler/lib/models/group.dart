import 'package:skeduler/models/color_shade.dart';
import 'package:skeduler/models/person.dart';
import 'package:skeduler/models/subject.dart';
import 'package:skeduler/models/timetable.dart';

class Group {
  /// properties
  String _groupDocId;

  String _name;
  String _description;
  ColorShade _colorShade;
  String _ownerEmail;
  String _ownerName;

  List<Profile> _people = [];
  List<Subject> _classes = [];
  List<Timetable> _timetables = [];

  /// constructor
  Group(
    String groupDocId, {
    String name = '',
    String description = '',
    ColorShade colorShade,
    String ownerEmail = '',
    String ownerName = '',
  }) {
    _groupDocId = groupDocId;

    _name = name;
    _description = description;
    _colorShade = colorShade;
    _ownerEmail = ownerEmail;
    _ownerName = ownerName;
  }

  /// getter methods
  String get groupDocId => _groupDocId;

  String get name => _name;
  String get description => _description;
  ColorShade get colorShade => _colorShade;
  String get ownerEmail => _ownerEmail;
  String get ownerName => _ownerName;
  int get numOfMembers => 1;

  List<Profile> get people => _people;
  List<Subject> get classes => _classes;
  List<Timetable> get timetables => _timetables;
}
