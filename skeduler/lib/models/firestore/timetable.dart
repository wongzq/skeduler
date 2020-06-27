import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/auxiliary/time.dart';

// --------------------------------------------------------------------------------
// TimetableMetadata class
// --------------------------------------------------------------------------------

class TimetableMetadata {
  // properties
  String docId;
  Timestamp startDate;
  Timestamp endDate;

  // constructors
  TimetableMetadata({
    this.docId,
    this.startDate,
    this.endDate,
  });

  // getter methods
  Map<String, dynamic> get asMap {
    return {
      'docId': this.docId,
      'startDate': this.startDate,
      'endDate': this.endDate,
    };
  }
}

// --------------------------------------------------------------------------------
// TimetableGroup class
// --------------------------------------------------------------------------------

class TimetableGroup {
  // properties
  String _docId;
  List<Weekday> _axisDay;
  List<Time> _axisTime;
  List<String> _axisCustom;

  TimetableGridDataList _gridDataList;

  // constructor
  TimetableGroup({
    String docId,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableGridDataList gridDataList,
  })  : this._docId = docId,
        this._axisDay = List<Weekday>.from(axisDay ?? []),
        this._axisTime = List<Time>.from(axisTime ?? []),
        this._axisCustom = List<String>.from(axisCustom ?? []),
        this._gridDataList =
            TimetableGridDataList.from(gridDataList ?? TimetableGridDataList());

  TimetableGroup.from(TimetableGroup group)
      : this._axisDay = List.from(group._axisDay ?? []),
        this._axisTime = List.from(group._axisTime ?? []),
        this._axisCustom = List.from(group._axisCustom ?? []),
        this._gridDataList = TimetableGridDataList.from(
            group._gridDataList ?? TimetableGridDataList());

  // getter methods
  String get docId => this._docId;
  List<Weekday> get axisDay => List.from(this._axisDay);
  List<Time> get axisTime => List.from(this._axisTime);
  List<String> get axisCustom => List.from(this._axisCustom);
  TimetableGridDataList get gridDataList => this._gridDataList;

  // get list as [List<String>]
  List<String> get axisDayStr => List.generate(
      this._axisDay.length, (index) => getWeekdayStr(this._axisDay[index]));
  List<String> get axisDayShortStr => List.generate(this._axisDay.length,
      (index) => getWeekdayShortStr(this._axisDay[index]));
  List<String> get axisTimeStr => List.generate(
      this._axisTime.length, (index) => getTimeStr(this._axisTime[index]));

  bool get isValid => this._axisDay == null ||
          this._axisTime == null ||
          this._axisCustom == null ||
          this._axisDay.isEmpty ||
          this._axisTime.isEmpty ||
          this._axisCustom.isEmpty
      ? false
      : true;

  // custom setter methods
  void _setAxisDay(List<Weekday> axisDay) {
    this._axisDay = axisDay;
    this._axisDay.sort((a, b) => a.index.compareTo(b.index));
  }

  void _setAxisTime(List<Time> axisTime) {
    this._axisTime = axisTime;
    this._axisTime.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void _setAxisCustom(List<String> axisCustom) {
    this._axisCustom = axisCustom;
  }

  void validateGridDataList({
    @required DateTime startDate,
    @required DateTime endDate,
    @required List<Member> members,
  }) {
    TimetableGridDataList tmpGridDataList =
        TimetableGridDataList.from(this.gridDataList);

    // loop through each gridData
    for (TimetableGridData gridData in tmpGridDataList.value) {
      // variables
      TimetableGridData newGridData = TimetableGridData.from(gridData);
      List<Time> timetableTimes;
      List<Time> memberTimes;
      Member member;

      if (gridData.dragData.member.docId != null &&
          gridData.dragData.member.docId.trim() != '') {
        // find member of gridData
        member = members.firstWhere(
          (groupMember) => groupMember.docId == gridData.dragData.member.docId,
          orElse: () => null,
        );

        if (member != null) {
          // set default availability of member
          bool memberIsAvailable = true;

          // get corresponding times based on 'alwaysAvailable' property
          memberTimes = member.alwaysAvailable
              ? member.timesUnavailable
              : member.timesAvailable;

          // timetable times
          timetableTimes = Time.generateTimes(
              months: List.generate(
                  Month.values.length, (index) => Month.values[index]),
              weekdays: [gridData.coord.day],
              time: gridData.coord.time,
              startDate: startDate,
              endDate: endDate);

          // loop through each timetableTime
          timetableTimesLoop:
          for (Time timetableTime in timetableTimes) {
            bool availableTimeOnSameDate = false;

            // loop through each memberTime to find time on same date
            for (Time memberTime in memberTimes) {
              if (timetableTime.sameDateAs(memberTime)) {
                availableTimeOnSameDate = true;

                // if member is always available, see unavailable times
                // if timetableTime is within unavailable times, result is false
                if (member.alwaysAvailable &&
                    !timetableTime.notWithinTimeOf(memberTime)) {
                  memberIsAvailable = false;
                  break timetableTimesLoop;
                }

                // if member is not always available, see available times
                // if timetableTime is not within available times, result is false
                if (!member.alwaysAvailable &&
                    !timetableTime.withinTimeOf(memberTime)) {
                  memberIsAvailable = false;
                  break timetableTimesLoop;
                }
              }
            }

            // if member is not always available and no matches on same date
            if (!member.alwaysAvailable && !availableTimeOnSameDate) {
              memberIsAvailable = false;
              break timetableTimesLoop;
            }
          }

          // update [available] in newGridData
          newGridData.available = memberIsAvailable;

          // update gridData in gridDataList
          this.gridDataList.pop(gridData);
          this.gridDataList.push(newGridData);
        } else {
          // if member not found, remove member from the gridData
          // update gridData in gridDataList
          newGridData.available = true;
          newGridData.dragData.member.docId = '';
          newGridData.dragData.member.display = '';
          this.gridDataList.pop(gridData);
          this.gridDataList.push(newGridData);
        }
      }
    }
  }

  Map<String, dynamic> asFirestoreMap() {
    Map<String, dynamic> groupMap = {};

    // convert axisDay
    if (this.axisDay != null) {
      List<int> axisDaysInt = [];
      this.axisDay.forEach((weekday) => axisDaysInt.add(weekday.index));
      axisDaysInt.sort((a, b) => a.compareTo(b));
      groupMap['axisDay'] = axisDaysInt;
    }

    // convert axisTime
    if (this.axisTime != null) {
      List<Map<String, Timestamp>> axisTimesTimestamps = [];
      this.axisTime.forEach((time) => axisTimesTimestamps.add({
            'startTime': Timestamp.fromDate(time.startTime),
            'endTime': Timestamp.fromDate(time.endTime),
          }));
      axisTimesTimestamps
          .sort((a, b) => a['startTime'].compareTo(b['startTime']));
      groupMap['axisTime'] = axisTimesTimestamps;
    }

    // convert axisCustom
    if (this.axisCustom != null) {
      groupMap['axisCustom'] = this.axisCustom;
    }

    // convert gridDataList
    if (this.gridDataList != null) {
      groupMap['gridDataList'] =
          this.gridDataList.value.map((e) => e.asFirestoreMap()).toList();
    }

    return groupMap;
  }
}

// --------------------------------------------------------------------------------
// Timetable class
// --------------------------------------------------------------------------------

class Timetable {
  // properties
  String _docId;
  DateTime _startDate;
  DateTime _endDate;

  GridAxis _gridAxisOfDay;
  GridAxis _gridAxisOfTime;
  GridAxis _gridAxisOfCustom;

  List<TimetableGroup> _groups;

  // constructors
  Timetable({
    @required String docId,
    Timestamp startDate,
    Timestamp endDate,
    GridAxis gridAxisOfDay,
    GridAxis gridAxisOfTime,
    GridAxis gridAxisOfCustom,
    List<TimetableGroup> groups,
  })  : this._docId = docId,
        this._startDate = startDate == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                startDate.millisecondsSinceEpoch),
        this._endDate = endDate == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                endDate.millisecondsSinceEpoch),
        this._gridAxisOfDay = gridAxisOfDay,
        this._gridAxisOfTime = gridAxisOfTime,
        this._gridAxisOfCustom = gridAxisOfCustom,
        this._groups = groups ?? [];

  // getter methods
  String get docId => this._docId;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  GridAxis get gridAxisOfDay => this._gridAxisOfDay;
  GridAxis get gridAxisOfTime => this._gridAxisOfTime;
  GridAxis get gridAxisOfCustom => this._gridAxisOfCustom;
  List<TimetableGroup> get groups => List.unmodifiable(this._groups);
  TimetableMetadata get metadata => TimetableMetadata(
      docId: this._docId,
      startDate: Timestamp.fromDate(this._startDate),
      endDate: Timestamp.fromDate(this._endDate));

  bool get isValid => this._docId != null &&
          this._docId.trim() != '' &&
          this._startDate != null &&
          this._endDate != null
      ? true
      : false;
}

// --------------------------------------------------------------------------------
// EditTimetable class
// --------------------------------------------------------------------------------

class EditTimetable extends ChangeNotifier {
  // properties
  String _docId;
  DateTime _startDate;
  DateTime _endDate;

  GridAxis _gridAxisOfDay;
  GridAxis _gridAxisOfTime;
  GridAxis _gridAxisOfCustom;

  List<TimetableGroup> _groups;

  bool _hasChanges;

  // constructors
  EditTimetable({
    String docId,
    DateTime startDate,
    DateTime endDate,
    GridAxis gridAxisOfDay,
    GridAxis gridAxisOfTime,
    GridAxis gridAxisOfCustom,
    List<TimetableGroup> groups,
  })  : this._docId = docId,
        this._startDate = startDate,
        this._endDate = endDate,
        this._gridAxisOfDay = gridAxisOfDay ?? GridAxis.x,
        this._gridAxisOfTime = gridAxisOfTime ?? GridAxis.y,
        this._gridAxisOfCustom = gridAxisOfCustom ?? GridAxis.z,
        this._groups = List.from(groups ?? []),
        this._hasChanges = false;

  EditTimetable.fromTimetable(Timetable ttb)
      : this(
            docId: ttb.docId,
            startDate: ttb.startDate,
            endDate: ttb.endDate,
            gridAxisOfDay: ttb.gridAxisOfDay,
            gridAxisOfTime: ttb.gridAxisOfTime,
            gridAxisOfCustom: ttb.gridAxisOfCustom,
            groups:
                ttb.groups.map((group) => TimetableGroup.from(group)).toList());

  EditTimetable.from(EditTimetable editTtb)
      : this(
            docId: editTtb.docId,
            startDate: editTtb.startDate,
            endDate: editTtb.endDate,
            gridAxisOfDay: editTtb.gridAxisOfDay,
            gridAxisOfTime: editTtb.gridAxisOfTime,
            gridAxisOfCustom: editTtb.gridAxisOfCustom,
            groups: editTtb.groups
                .map((group) => TimetableGroup.from(group))
                .toList());

  // getter methods
  String get docId => this._docId;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  GridAxis get gridAxisOfDay => this._gridAxisOfDay;
  GridAxis get gridAxisOfTime => this._gridAxisOfTime;
  GridAxis get gridAxisOfCustom => this._gridAxisOfCustom;
  List<TimetableGroup> get groups => this._groups;

  TimetableMetadata get metadata => TimetableMetadata(
      docId: this._docId,
      startDate: Timestamp.fromDate(this._startDate),
      endDate: Timestamp.fromDate(this._endDate));

  bool get isValid => this._docId != null &&
          this._docId.trim() != '' &&
          this._startDate != null &&
          this._endDate != null &&
          this._startDate.isBefore(this._endDate)
      ? true
      : false;

  bool get hasChanges =>
      this._hasChanges ||
      this
          ._groups
          .contains((TimetableGroup group) => group.gridDataList.hasChanges);

  bool get groupsAreValid {
    for (TimetableGroup group in this.groups) {
      if (!group.isValid) return false;
    }
    return true;
  }

  // setter methods
  set docId(String docId) {
    this._docId = docId;
    notifyListeners();
  }

  set startDate(DateTime startDate) {
    this._startDate = startDate;
    this._changed();
  }

  set endDate(DateTime endDate) {
    this._endDate = endDate;
    this._changed();
  }

  set gridAxisOfDay(GridAxis gridAxis) {
    this._gridAxisOfDay = gridAxis;
    this._changed();
  }

  set gridAxisOfTime(GridAxis gridAxis) {
    this._gridAxisOfTime = gridAxis;
    this._changed();
  }

  set gridAxisOfCustom(GridAxis gridAxis) {
    this._gridAxisOfCustom = gridAxis;
    this._changed();
  }

  set groups(List<TimetableGroup> value) {
    this._groups = value;
    this._changed();
  }

  void setGroupAxisDay(int groupIndex, List<Weekday> axisDay) {
    this._groups[groupIndex]._setAxisDay(axisDay);
    this._changed();
  }

  void setGroupAxisTime(int groupIndex, List<Time> axisTime) {
    this._groups[groupIndex]._setAxisTime(axisTime);
    this._changed();
  }

  void setGroupAxisCustom(int groupIndex, List<String> axisCustom) {
    this._groups[groupIndex]._setAxisCustom(axisCustom);
    this._changed();
  }

  set hasChanges(bool value) {
    this._hasChanges = value;
    notifyListeners();
  }

  void validateAllGridDataList(List<Member> members) {
    for (TimetableGroup group in this._groups) {
      group.validateGridDataList(
        startDate: this.startDate,
        endDate: this.endDate,
        members: members,
      );
    }
    this._changed();
  }

  void updateTimetableSettings({
    String docId,
    DateTime startDate,
    DateTime endDate,
    List<TimetableGroup> groups,
    List<Member> members,
  }) {
    this.docId = docId ?? this.docId;
    this.startDate = startDate ?? this.startDate;
    this.endDate = endDate ?? this.endDate;
    this._groups = groups ?? [];

    for (int i = 0; i < this._groups.length; i++) {
      this._groups[i].validateGridDataList(
          startDate: this.startDate, endDate: this.endDate, members: members);
    }

    this._changed();
  }

  void updateTimetableFromCopy(Timetable ttb, List<Member> members) {
    this._gridAxisOfDay = ttb.gridAxisOfDay;
    this._gridAxisOfTime = ttb.gridAxisOfTime;
    this._gridAxisOfCustom = ttb.gridAxisOfCustom;
    this._groups = List.from(ttb.groups);

    for (TimetableGroup group in this._groups) {
      group.validateGridDataList(
        startDate: this.startDate,
        endDate: this.endDate,
        members: members,
      );
    }
    this._changed();
  }

  void updateTimetableFromCopyAxes(Timetable ttb) {
    this._gridAxisOfDay = ttb.gridAxisOfDay;
    this._gridAxisOfTime = ttb.gridAxisOfTime;
    this._gridAxisOfCustom = ttb.gridAxisOfCustom;
    this._groups = List.from(ttb.groups);

    for (TimetableGroup group in this._groups) {
      group._gridDataList = TimetableGridDataList();
    }
    this._changed();
  }

  void updateAxisTimeValue({
    @required int groupIndex,
    @required Time prev,
    @required Time next,
  }) {
    TimetableGridDataList tmpGridDataList =
        TimetableGridDataList.from(this.groups[groupIndex].gridDataList);

    for (TimetableGridData gridData in tmpGridDataList.value) {
      // find coord to be replaced
      if (gridData.coord.time == prev) {
        TimetableGridData newGridData = TimetableGridData.from(gridData);
        newGridData.coord.time = next;

        this.groups[groupIndex].gridDataList.pop(gridData);
        this.groups[groupIndex].gridDataList.push(newGridData);
      }
    }
    this._changed();
  }

  void updateAxisCustomValue({
    @required int groupIndex,
    @required String prev,
    @required String next,
  }) {
    TimetableGridDataList tmpGridDataList =
        TimetableGridDataList.from(this.groups[groupIndex].gridDataList);

    for (TimetableGridData gridData in tmpGridDataList.value) {
      if (gridData.coord.custom == prev) {
        TimetableGridData tmpGridData = TimetableGridData.from(gridData);
        tmpGridData.coord.custom = next;

        this.groups[groupIndex].gridDataList.pop(gridData);
        this.groups[groupIndex].gridDataList.push(tmpGridData);
      }
    }
    this._changed();
  }

  void _changed() {
    this._hasChanges = true;
    notifyListeners();
  }

// convert from [EditTimetable] to Firestore's [Map<String, dynamic>] format
  Map<String, dynamic> asFirestoreMap() {
    Map<String, dynamic> firestoreMap = {};

    // convert startDate and endDate
    firestoreMap['startDate'] = Timestamp.fromDate(this.startDate);
    firestoreMap['endDate'] = Timestamp.fromDate(this.endDate);

    // convert gridAxisTypes
    if (this.gridAxisOfDay == null ||
        this.gridAxisOfTime == null ||
        this.gridAxisOfCustom == null) {
      firestoreMap['gridAxisOfDay'] = GridAxis.x.index;
      firestoreMap['gridAxisOfTime'] = GridAxis.y.index;
      firestoreMap['gridAxisOfCustom'] = GridAxis.z.index;
    } else {
      List<GridAxis> gridAxisTypes = [
        this.gridAxisOfDay,
        this.gridAxisOfTime,
        this.gridAxisOfCustom,
      ];

      if (gridAxisTypes.contains(GridAxis.x) &&
          gridAxisTypes.contains(GridAxis.y) &&
          gridAxisTypes.contains(GridAxis.z)) {
        firestoreMap['gridAxisOfDay'] = this.gridAxisOfDay.index;
        firestoreMap['gridAxisOfTime'] = this.gridAxisOfTime.index;
        firestoreMap['gridAxisOfCustom'] = this.gridAxisOfCustom.index;
      } else {
        firestoreMap['gridAxisOfDay'] = GridAxis.x.index;
        firestoreMap['gridAxisOfTime'] = GridAxis.y.index;
        firestoreMap['gridAxisOfCustom'] = GridAxis.z.index;
      }
    }

    firestoreMap['groups'] =
        this.groups.map((e) => e.asFirestoreMap()).toList();

    // return final map in firestore format
    return firestoreMap;
  }
}

// --------------------------------------------------------------------------------
// Auxiliary functions
// --------------------------------------------------------------------------------

// check if all [Timetable] in [List<Timetable>] is consecutive with no conflicts of date
bool isConsecutiveTimetables(List<TimetableMetadata> ttbMetadatas) {
  bool isConsecutive = true;

  // sort the area in terms of startDate
  ttbMetadatas.sort((a, b) {
    return a.startDate.compareTo(b.startDate);
  });

  // loop through the array to find any date conflict
  for (int i = 0; i < ttbMetadatas.length; i++) {
    if (i != 0) {
      // if conflict is found, sets [isConsecutive] as [false]
      if (!(ttbMetadatas[i - 1]
              .startDate
              .toDate()
              .isBefore(ttbMetadatas[i].startDate.toDate()) &&
          ttbMetadatas[i - 1]
              .endDate
              .toDate()
              .isBefore(ttbMetadatas[i].endDate.toDate()) &&
          (ttbMetadatas[i - 1]
                  .endDate
                  .toDate()
                  .isBefore(ttbMetadatas[i].startDate.toDate()) ||
              ttbMetadatas[i - 1]
                  .endDate
                  .toDate()
                  .isAtSameMomentAs(ttbMetadatas[i].startDate.toDate())))) {
        isConsecutive = false;
        break;
      }
    }
  }

  return isConsecutive;
}
