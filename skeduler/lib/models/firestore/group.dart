import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/auxiliary/conflict.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/subject.dart';
import 'package:skeduler/models/firestore/timetable.dart';

// --------------------------------------------------------------------------------
// Group class
// --------------------------------------------------------------------------------

class Group {
  // properties
  String _docId;

  String _name;
  ColorShade _colorShade;
  String _ownerEmail;
  String _ownerName;

  List<TimetableMetadata> _timetableMetadatas;
  List<String> _memberMetadatas;
  List<String> _subjectMetadatas;
  List<Conflict> _conflicts;

  // constructors
  Group({
    @required String docId,
    String name = '',
    ColorShade colorShade,
    String ownerEmail = '',
    String ownerName = '',
    List<TimetableMetadata> timetableMetadatas = const [],
    List<String> memberMetadatas = const [],
    List<String> subjectMetadatas = const [],
    List<Conflict> conflicts = const [],
  }) {
    this._docId = docId;

    this._name = name;
    this._colorShade = colorShade;
    this._ownerEmail = ownerEmail;
    this._ownerName = ownerName;

    this._timetableMetadatas = List.from(timetableMetadatas);
    this._memberMetadatas = List.from(memberMetadatas);
    this._subjectMetadatas = List.from(subjectMetadatas);
    this._conflicts = List.from(conflicts);
  }

  // getter methods
  String get docId => this._docId;

  String get name => this._name;
  ColorShade get colorShade => this._colorShade ?? ColorShade();
  String get ownerEmail => this._ownerEmail;
  String get ownerName => this._ownerName;
  int get numOfMembers => this._memberMetadatas.length;

  List<TimetableMetadata> get timetableMetadatas => this._timetableMetadatas;
  List<String> get memberMetadatas => this._memberMetadatas;
  List<String> get subjectMetadatas => this._subjectMetadatas;
  List<Conflict> get conflicts => this._conflicts;
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
// Group Status class for Provider
// --------------------------------------------------------------------------------

class GroupStatus extends ChangeNotifier {
  // properties
  Group _group;
  List<Member> _members;
  List<Subject> _subjects;

  Member _me;

  /// constructors
  GroupStatus({
    Group group,
    List<Member> members,
    List<Subject> subjects,
    Member me,
  })  : this._group = group,
        this._members = members ?? [],
        this._subjects = subjects ?? [],
        this._me = me;

  // getter methods
  Group get group => this._group;
  List<Member> get members => this._members;
  List<Subject> get subjects => reorderSubjects(
        subjects: this._subjects,
        subjectMetadatas: this._group._subjectMetadatas,
      );
  Member get me => this._me;

  void reset() {
    this._group = null;
    this._members = null;
    this._subjects = null;
    this._me = null;
    notifyListeners();
  }

  // auxiliary functions
  static List<Subject> reorderSubjects({
    @required List<Subject> subjects,
    @required List<String> subjectMetadatas,
  }) {
    List<Subject> reorderedSubjects = [];

    for (int i = 0; i < subjectMetadatas.length; i++) {
      Subject subjectFound = subjects.firstWhere(
        (subject) => subject.docId == subjectMetadatas[i],
        orElse: () => null,
      );

      if (subjectFound != null) {
        reorderedSubjects.add(subjectFound);
      }
    }

    return reorderedSubjects;
  }
}
