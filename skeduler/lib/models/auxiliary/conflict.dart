import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:flutter/foundation.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';

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

  static List<Conflict> generateConflicts({
    @required List<Timetable> timetables,
    @required List<Member> members,
  }) {
    List<Conflict> conflicts = [];

    // iterate through timetables
    for (Timetable timetable in timetables) {
      // iterate through timetable groups
      for (TimetableGroup group in timetable.groups) {
        int groupIndex = timetable.groups.indexOf(group);

        // iterate through gridDataList
        for (TimetableGridData gridData in group.gridDataList.value) {
          // if gridData has member
          if (gridData.dragData.member.docId != null &&
              gridData.dragData.member.docId.trim() != '') {
            // get timetable times
            List<Time> timetableTimes = Time.generateTimes(
                months: List.generate(
                    Month.values.length, (index) => Month.values[index]),
                weekdays: List.generate(
                    Weekday.values.length, (index) => Weekday.values[index]),
                time: gridData.coord.time,
                startDate: timetable.startDate,
                endDate: timetable.endDate);

            // find member
            Member member = members.firstWhere(
                (elem) => elem.docId == gridData.dragData.member.docId,
                orElse: () => null);

            // if member not found
            if (member == null) {
              // initialize conflictDates
              List<DateTime> conflictDates = [];

              // iterate through timetable times
              for (Time timetableTime in timetableTimes) {
                conflictDates.add(timetableTime.startDate);
              }

              // create new conflict if conflictDates exist
              if (conflictDates.length > 0) {
                conflicts.add(Conflict(
                    timetable: timetable.docId,
                    groupIndex: groupIndex,
                    gridData: gridData,
                    member: MemberMetadata(
                        docId: member.docId,
                        name: member.name,
                        nickname: member.nickname),
                    conflictDates: conflictDates));
              }
            }
            // if member found
            else {
              // get member times
              List<Time> memberTimes = member.alwaysAvailable
                  ? member.timesUnavailable
                  : member.timesAvailable;

              // initialize conflictDates
              List<DateTime> conflictDates = [];

              // iterate through timetable times
              for (Time timetableTime in timetableTimes) {
                bool availableTimeFound = false;

                // iterate through member times
                for (Time memberTime in memberTimes) {
                  // if member is always available, check unavailable times
                  // if timetableTime is within unavailable times, member is not available
                  if (member.alwaysAvailable &&
                      !timetableTime.notWithinDateTimeOf(memberTime)) {
                    conflictDates.add(timetableTime.startDate);
                    break;
                  }
                  // if member is not always available, check available times
                  // if timetableTime is not within available times, member is ot available
                  else if (!member.alwaysAvailable &&
                      timetableTime.withinDateTimeOf(memberTime)) {
                    availableTimeFound = true;
                    break;
                  }
                }

                // member is not always available and if no available time found
                if (!member.alwaysAvailable && !availableTimeFound) {
                  conflictDates.add(timetableTime.startDate);
                }
              }

              // create new conflict if conflictDates exist
              if (conflictDates.length > 0) {
                conflicts.add(Conflict(
                    timetable: timetable.docId,
                    groupIndex: groupIndex,
                    gridData: gridData,
                    member: MemberMetadata(
                        docId: member.docId,
                        name: member.name,
                        nickname: member.nickname),
                    conflictDates: conflictDates));
              }
            }
          }
        }
      }
    }
    return conflicts;
  }
}
