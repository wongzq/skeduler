import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/timetable.dart';

class Group {
  /// properties
  String _docId;

  String _name;
  String _description;
  ColorShade _colorShade;
  String _ownerEmail;
  String _ownerName;

  List<String> _members;
  List<TimetableMetadata> _timetables;

  /// constructors
  Group({
    @required String docId,
    String name = '',
    String description = '',
    ColorShade colorShade,
    String ownerEmail = '',
    String ownerName = '',
    List<String> members = const [],
    List<TimetableMetadata> timetableMetadatas = const [],
  }) {
    _docId = docId;

    _name = name;
    _description = description;
    _colorShade = colorShade;
    _ownerEmail = ownerEmail;
    _ownerName = ownerName;

    _members = [];
    members.forEach((member) => _members.add(member));
    _timetables = [];
    timetableMetadatas.forEach((timetable) => _timetables.add(timetable));
  }

  /// getter methods
  String get docId => _docId;

  String get name => _name;
  String get description => _description;
  ColorShade get colorShade => _colorShade ?? ColorShade();
  String get ownerEmail => _ownerEmail;
  String get ownerName => _ownerName;
  int get numOfMembers => _members.length;
  List<String> get members => _members;
  List<TimetableMetadata> get timetables => _timetables;
}

class GroupMetadata extends ChangeNotifier {
  String _docId;
  String _name;

  GroupMetadata({docId, groupName}) {
    _docId = docId;
    _name = groupName;
    notifyListeners();
  }

  String get docId => _docId;
  String get name => _name;

  set docId(String value) {
    _docId = value;
    notifyListeners();
  }

  set name(String value) {
    _name = value;
    notifyListeners();
  }
}
