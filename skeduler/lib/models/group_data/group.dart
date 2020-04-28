import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/models/group_data/timetable.dart';

class GroupStatus extends ChangeNotifier {
  Group _group;
  bool _hasChanges;

  GroupStatus({
    Group group,
    bool hasChanges = false,
  })  : _group = group,
        _hasChanges = hasChanges;

  Group get group => this._group;
  bool get hasChanges => this._hasChanges;

  set group(value) {
    this._group = group;
    notifyListeners();
  }

  set hasChanges(value) {
    this._hasChanges = value;
    notifyListeners();
  }
}

class Group {
  /// properties
  String _docId;

  String _name;
  String _description;
  ColorShade _colorShade;
  String _ownerEmail;
  String _ownerName;

  List<TimetableMetadata> _timetableMetadatas;
  List<String> _members;
  List<Subject> _subjects;

  /// constructors
  Group({
    @required String docId,
    String name = '',
    String description = '',
    ColorShade colorShade,
    String ownerEmail = '',
    String ownerName = '',
    List<TimetableMetadata> timetableMetadatas = const [],
    List<String> members = const [],
    List<Subject> subjects = const [],
  }) {
    _docId = docId;

    _name = name;
    _description = description;
    _colorShade = colorShade;
    _ownerEmail = ownerEmail;
    _ownerName = ownerName;

    _timetableMetadatas = List.from(timetableMetadatas);
    _members = List.from(members);
    _subjects = List.from(subjects);
  }

  /// getter methods
  String get docId => _docId;

  String get name => _name;
  String get description => _description;
  ColorShade get colorShade => _colorShade ?? ColorShade();
  String get ownerEmail => _ownerEmail;
  String get ownerName => _ownerName;
  int get numOfMembers => _members.length;
  List<TimetableMetadata> get timetableMetadatas => _timetableMetadatas;
  List<String> get members => _members;
  List<Subject> get subjects => _subjects;
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
