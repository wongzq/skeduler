import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';

class Group {
  /// properties
  String _groupDocId;

  String _name;
  String _description;
  ColorShade _colorShade;
  String _ownerEmail;
  String _ownerName;

  List<String> _members;
  List<String> _timetables;

  /// constructor
  Group({
    @required String groupDocId,
    String name = '',
    String description = '',
    ColorShade colorShade,
    String ownerEmail = '',
    String ownerName = '',
    List<dynamic> members = const [],
    List<dynamic> timetables = const [],
  }) {
    _groupDocId = groupDocId;

    _name = name;
    _description = description;
    _colorShade = colorShade;
    _ownerEmail = ownerEmail;
    _ownerName = ownerName;

    _members = [];
    members.forEach((member) => _members.add(member));
    _timetables = [];
    timetables.forEach((timetable) => _timetables.add(timetable));
  }

  /// getter methods
  String get groupDocId => _groupDocId;

  String get name => _name;
  String get description => _description;
  ColorShade get colorShade => _colorShade ?? ColorShade();
  String get ownerEmail => _ownerEmail;
  String get ownerName => _ownerName;
  // int get numOfMembers => 1;
  int get numOfMembers => _members.length;
  List<String> get members => _members;
  List<String> get timetables => _timetables;
}

class GroupMetadata extends ChangeNotifier {
  String _docId;
  String _name;

  GroupMetadata({groupDocId, groupName}) {
    _docId = groupDocId;
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
