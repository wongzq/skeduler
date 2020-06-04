import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/timetable.dart';

class Conflict {
  TimetableGridData gridData;
  TimetableMetadata timetable;
  MemberMetadata member;
  List<DateTime> conflictDates;

  Conflict({
    this.gridData,
    this.timetable,
    this.member,
    this.conflictDates,
  });
}
