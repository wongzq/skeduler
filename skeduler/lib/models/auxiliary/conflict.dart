import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/timetable.dart';

class Conflict {
  TimetableMetadata timetable;
  TimetableGridData gridData;
  MemberMetadata member;
  List<DateTime> conflictDates;

  Conflict({
    this.timetable,
    this.gridData,
    this.member,
    this.conflictDates,
  });
}
