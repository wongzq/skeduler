import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:flutter/foundation.dart';

class Conflict {
  String _timetable;
  int _groupIndex;
  TimetableGridData _gridData;
  MemberMetadata _member;
  List<DateTime> _conflictDates;

  Conflict({
    String timetable,
    @required int groupIndex,
    TimetableGridData gridData,
    MemberMetadata member,
    List<DateTime> conflictDates,
  })  : this._timetable = timetable,
        this._groupIndex = groupIndex,
        this._gridData = gridData,
        this._member = member,
        this._conflictDates = conflictDates;

  String get timetable => this._timetable;
  int get groupIndex => this._groupIndex;
  TimetableGridData get gridData => this._gridData;
  MemberMetadata get member => this._member;
  List<DateTime> get conflictDates => this._conflictDates;
}
