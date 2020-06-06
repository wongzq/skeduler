import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/member.dart';

class Conflict {
  String _timetable;
  MemberMetadata _member;
  TimetableGridData _gridData;
  List<DateTime> _conflictDates;

  Conflict({
    String timetable,
    MemberMetadata member,
    TimetableGridData gridData,
    List<DateTime> conflictDates,
  })  : this._timetable = timetable,
        this._gridData = gridData,
        this._member = member,
        this._conflictDates = conflictDates;

  String get timetable => this._timetable;
  TimetableGridData get gridData => this._gridData;
  MemberMetadata get member => this._member;
  List<DateTime> get conflictDates => this._conflictDates;
}
