import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/models/group_data/timetable.dart';

// --------------------------------------------------------------------------------
// Group class
// --------------------------------------------------------------------------------

class Group {
  // properties
  String _docId;

  String _name;
  String _description;
  ColorShade _colorShade;
  String _ownerEmail;
  String _ownerName;

  List<TimetableMetadata> _timetableMetadatas;
  List<String> _members;
  List<Subject> _subjects;

  // constructors
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
    this._docId = docId;

    this._name = name;
    this._description = description;
    this._colorShade = colorShade;
    this._ownerEmail = ownerEmail;
    this._ownerName = ownerName;

    this._timetableMetadatas = List.from(timetableMetadatas);
    this._members = List.from(members);
    this._subjects = List.from(subjects);
  }

  // getter methods
  String get docId => this._docId;

  String get name => this._name;
  String get description => this._description;
  ColorShade get colorShade => this._colorShade ?? ColorShade();
  String get ownerEmail => this._ownerEmail;
  String get ownerName => this._ownerName;
  int get numOfMembers => this._members.length;

  List<TimetableMetadata> get timetableMetadatas => this._timetableMetadatas;
  List<String> get members => this._members;
  List<Subject> get subjects => this._subjects;
}

// --------------------------------------------------------------------------------
// Group Metadata class for Provider
// --------------------------------------------------------------------------------

class GroupMetadata extends ChangeNotifier {
  String _docId;
  String _name;

  GroupMetadata({docId, groupName}) {
    this._docId = docId;
    this._name = groupName;
    notifyListeners();
  }

  String get docId => this._docId;
  String get name => this._name;

  set docId(String value) {
    this._docId = value;
    notifyListeners();
  }

  set name(String value) {
    this._name = value;
    notifyListeners();
  }
}

// --------------------------------------------------------------------------------
// Members Metadata class for Provider
// --------------------------------------------------------------------------------

class MembersStatus extends ChangeNotifier {
  // properties
  List<Member> _members;

  // constructors
  MembersStatus({List<Member> members}) : this._members = members ?? [];

  // getter methods
  List<Member> get members => List.unmodifiable(this._members);
}

// --------------------------------------------------------------------------------
// Group Status class for Provider
// --------------------------------------------------------------------------------

class GroupStatus extends ChangeNotifier {
  // properties
  Group _group;
  List<Member> _members;

  bool _hasChanges;

  /// constructors
  GroupStatus({
    Group group,
    List<Member> members,
    bool hasChanges = false,
  })  : _group = group,
        _members = members ?? [],
        _hasChanges = hasChanges;

  // getter methods
  Group get group => this._group;
  List<Member> get members => this._members;
  bool get hasChanges => this._hasChanges;

  // setter methods
  set group(value) {
    this._group = group;
    notifyListeners();
  }

  set members(value) {
    this._members = members;
    notifyListeners();
  }

  set hasChanges(value) {
    this._hasChanges = value;
    notifyListeners();
  }
}
