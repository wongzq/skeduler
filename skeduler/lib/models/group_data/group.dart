import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/models/group_data/timetable.dart';

class Group {
  /// properties
  String _groupDocId;

  String _name;
  String _description;
  ColorShade _colorShade;
  String _ownerEmail;
  String _ownerName;

  List<Member> _members = [];
  List<Subject> _classes = [];
  List<Timetable> _timetables = [];

  /// constructor
  Group({
    @required String groupDocId,
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

  List<Member> get members => _members;
  List<Subject> get classes => _classes;
  List<Timetable> get timetables => _timetables;
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
