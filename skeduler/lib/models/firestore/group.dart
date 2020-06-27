import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
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
  }) {
    this._docId = docId;

    this._name = name;
    this._colorShade = colorShade;
    this._ownerEmail = ownerEmail;
    this._ownerName = ownerName;

    this._timetableMetadatas = List.from(timetableMetadatas);
    this._memberMetadatas = List.from(memberMetadatas);
    this._subjectMetadatas = List.from(subjectMetadatas);
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
  List<Timetable> _timetables;

  Member _me;
  String _memberDocId;

  /// constructors
  GroupStatus({
    Group group,
    List<Member> members,
    List<Subject> subjects,
    List<Timetable> timetables,
    Member me,
    Member memberDocId,
  })  : this._group = group,
        this._members = members ?? [],
        this._subjects = subjects ?? [],
        this._timetables = timetables ?? [],
        this._me = me;

  // getter methods
  Group get group => this._group;
  List<Member> get members => this._members;
  List<Subject> get subjects => reorderSubjects(
        subjects: this._subjects,
        subjectMetadatas: this._group._subjectMetadatas,
      );
  List<Timetable> get timetables => this._timetables;
  Member get me => this._me;
  Member get member => this._members == null
      ? null
      : this._members.firstWhere(
          (elem) => elem.docId == this._memberDocId,
          orElse: () {
            this._memberDocId = null;
            return this._me;
          },
        );

  void update({
    @required Group newGroup,
    @required List<Member> newMembers,
    @required List<Subject> newSubjects,
    @required List<Timetable> newTimetables,
    @required Member newMe,
  }) {
    this._group = newGroup;
    this._members = newMembers;
    this._subjects = newSubjects;
    this._timetables = newTimetables;
    this._me = newMe;
    this._memberDocId = this._members == null
        ? null
        : this._members.firstWhere(
                      (elem) => elem.docId == this._memberDocId,
                      orElse: () => null,
                    ) ==
                null
            ? null
            : this._memberDocId;
    notifyListeners();
  }

  set memberDocId(String value) {
    this._memberDocId = value;
    notifyListeners();
  }

  void reset() {
    this._group = null;
    this._members = null;
    this._subjects = null;
    this._timetables = null;
    this._me = null;
    this._memberDocId = null;
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
