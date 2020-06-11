import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/time.dart';

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

  List<Weekday> _axisDay = [];
  List<Time> _axisTime = [];
  List<String> _axisCustom = [];

  TimetableGridDataList _gridDataList = TimetableGridDataList();

  // constructors
  Timetable({
    @required String docId,
    Timestamp startDate,
    Timestamp endDate,
    GridAxis gridAxisOfDay,
    GridAxis gridAxisOfTime,
    GridAxis gridAxisOfCustom,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableGridDataList gridDataList,
  }) {
    // documentID
    this._docId = docId;

    // timetable start date
    if (startDate != null)
      this._startDate =
          DateTime.fromMillisecondsSinceEpoch(startDate.millisecondsSinceEpoch);

    // timetable end date
    if (endDate != null)
      this._endDate =
          DateTime.fromMillisecondsSinceEpoch(endDate.millisecondsSinceEpoch);

    // timetable days axis
    if (gridAxisOfDay != null) this._gridAxisOfDay = gridAxisOfDay;
    if (axisDay != null) this._axisDay = List<Weekday>.from(axisDay ?? []);

    // timetable times axis
    if (gridAxisOfTime != null) this._gridAxisOfTime = gridAxisOfTime;
    if (axisTime != null) this._axisTime = List<Time>.from(axisTime ?? []);

    // timetable custom axis
    if (gridAxisOfCustom != null) this._gridAxisOfCustom = gridAxisOfCustom;
    if (axisCustom != null)
      this._axisCustom = List<String>.from(axisCustom ?? []);

    if (gridDataList != null)
      this._gridDataList =
          TimetableGridDataList.from(gridDataList ?? TimetableGridDataList());
  }

  // getter methods
  String get docId => this._docId;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  GridAxis get gridAxisOfDay => this._gridAxisOfDay;
  GridAxis get gridAxisOfTime => this._gridAxisOfTime;
  GridAxis get gridAxisOfCustom => this._gridAxisOfCustom;
  List<Weekday> get axisDay => this._axisDay;
  List<Time> get axisTime => this._axisTime;
  List<String> get axisCustom => this._axisCustom;
  TimetableGridDataList get gridDataList => this._gridDataList;

  // get list as [List<String>]
  List<String> get axisDayStr => List.generate(
      this._axisDay.length, (index) => getWeekdayStr(this._axisDay[index]));
  List<String> get axisDayShortStr => List.generate(this._axisDay.length,
      (index) => getWeekdayShortStr(this._axisDay[index]));
  List<String> get axisTimeStr => List.generate(
      this._axisTime.length, (index) => getTimeStr(this._axisTime[index]));

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

  List<Weekday> _axisDay;
  List<Time> _axisTime;
  List<String> _axisCustom;

  TimetableGridDataList _gridDataList;

  bool _hasChanges;

  // constructors
  EditTimetable({
    String docId,
    DateTime startDate,
    DateTime endDate,
    GridAxis gridAxisOfDay,
    GridAxis gridAxisOfTime,
    GridAxis gridAxisOfCustom,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableGridDataList gridDataList,
  })  : this._docId = docId,
        this._startDate = startDate,
        this._endDate = endDate,
        this._gridAxisOfDay = gridAxisOfDay ?? GridAxis.x,
        this._gridAxisOfTime = gridAxisOfTime ?? GridAxis.y,
        this._gridAxisOfCustom = gridAxisOfCustom ?? GridAxis.z,
        this._axisDay = List<Weekday>.from(axisDay ?? []),
        this._axisTime = List<Time>.from(axisTime ?? []),
        this._axisCustom = List<String>.from(axisCustom ?? []),
        this._gridDataList =
            TimetableGridDataList.from(gridDataList ?? TimetableGridDataList()),
        this._hasChanges = false;

  EditTimetable.fromTimetable(Timetable ttb)
      : this(
          docId: ttb.docId,
          startDate: ttb.startDate,
          endDate: ttb.endDate,
          gridAxisOfDay: ttb.gridAxisOfDay,
          gridAxisOfTime: ttb.gridAxisOfTime,
          gridAxisOfCustom: ttb.gridAxisOfCustom,
          axisDay: ttb.axisDay,
          axisTime: ttb.axisTime,
          axisCustom: ttb.axisCustom,
          gridDataList: ttb.gridDataList,
        );

  EditTimetable.from(EditTimetable editTtb)
      : this(
          docId: editTtb.docId,
          startDate: editTtb.startDate,
          endDate: editTtb.endDate,
          gridAxisOfDay: editTtb.gridAxisOfDay,
          gridAxisOfTime: editTtb.gridAxisOfTime,
          gridAxisOfCustom: editTtb.gridAxisOfCustom,
          axisDay: List.from(editTtb.axisDay),
          axisTime: List.from(editTtb.axisTime),
          axisCustom: List.from(editTtb.axisCustom),
          gridDataList: TimetableGridDataList.from(editTtb.gridDataList),
        );

  // getter methods
  String get docId => this._docId;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  GridAxis get gridAxisOfDay => this._gridAxisOfDay;
  GridAxis get gridAxisOfTime => this._gridAxisOfTime;
  GridAxis get gridAxisOfCustom => this._gridAxisOfCustom;
  List<Weekday> get axisDay => this._axisDay;
  List<Time> get axisTime => this._axisTime;
  List<String> get axisCustom => this._axisCustom;
  TimetableGridDataList get gridDataList => this._gridDataList;
  TimetableMetadata get metadata => TimetableMetadata(
        docId: this._docId,
        startDate: Timestamp.fromDate(this._startDate),
        endDate: Timestamp.fromDate(this._endDate),
      );

  bool get isValid => this._docId != null &&
          this._docId.trim() != '' &&
          this._startDate != null &&
          this._endDate != null
      ? true
      : false;
  bool get hasChanges => this._hasChanges || this._gridDataList.hasChanges;

  // get list as [List<String>]
  List<String> get axisDayStr =>
      List.generate(_axisDay.length, (index) => getWeekdayStr(_axisDay[index]));
  List<String> get axisDayShortStr => List.generate(
      _axisDay.length, (index) => getWeekdayShortStr(_axisDay[index]));
  List<String> get axisTimeStr =>
      List.generate(_axisTime.length, (index) => getTimeStr(_axisTime[index]));

  // setter methods
  set docId(String docId) {
    this._docId = docId;
    notifyListeners();
  }

  set startDate(DateTime startDate) {
    this._startDate = startDate;
    this._hasChanges = true;
    notifyListeners();
  }

  set endDate(DateTime endDate) {
    this._endDate = endDate;
    this._hasChanges = true;
    notifyListeners();
  }

  set gridAxisOfDay(GridAxis gridAxis) {
    this._gridAxisOfDay = gridAxis;
    this._hasChanges = true;
    notifyListeners();
  }

  set gridAxisOfTime(GridAxis gridAxis) {
    this._gridAxisOfTime = gridAxis;
    this._hasChanges = true;
    notifyListeners();
  }

  set gridAxisOfCustom(GridAxis gridAxis) {
    this._gridAxisOfCustom = gridAxis;
    this._hasChanges = true;
    notifyListeners();
  }

  set axisDay(List<Weekday> axisDay) {
    this._axisDay = axisDay;
    this._axisDay.sort((a, b) => a.index.compareTo(b.index));
    this._hasChanges = true;
    notifyListeners();
  }

  set axisTime(List<Time> axisTime) {
    this._axisTime = axisTime;
    this._axisTime.sort((a, b) => a.startTime.compareTo(b.startTime));
    this._hasChanges = true;
    notifyListeners();
  }

  set axisCustom(List<String> axisCustom) {
    this._axisCustom = axisCustom;
    this._hasChanges = true;
    notifyListeners();
  }

  set gridDataList(TimetableGridDataList gridDataList) {
    this._gridDataList = gridDataList;
    this._hasChanges = true;
    notifyListeners();
  }

  set hasChanges(bool value) {
    this._hasChanges = value;
    this._gridDataList.hasChanges = value;
    notifyListeners();
  }

  void updateTimetableSettings({
    String docId,
    DateTime startDate,
    DateTime endDate,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableGridDataList gridDataList,
  }) {
    this.docId = docId ?? this.docId;
    this.startDate = startDate ?? this.startDate;
    this.endDate = endDate ?? this.endDate;
    this.axisDay = axisDay ?? this.axisDay;
    this.axisTime = axisTime ?? this.axisTime;
    this.axisCustom = axisCustom ?? this.axisCustom;
    this.gridDataList = gridDataList ?? this.gridDataList;
    this._hasChanges = true;
    notifyListeners();
  }

  void updateTimetableFromCopy(Timetable ttb, List<Member> members) {
    this._gridAxisOfDay = ttb.gridAxisOfDay;
    this._gridAxisOfTime = ttb.gridAxisOfTime;
    this._gridAxisOfCustom = ttb.gridAxisOfCustom;
    this._axisDay = ttb.axisDay;
    this._axisTime = ttb.axisTime;
    this._axisCustom = ttb.axisCustom;
    this._gridDataList = ttb.gridDataList;
    this.validateGridDataList(members: members);
    notifyListeners();
  }

  void updateTimetableFromCopyAxes(Timetable ttb) {
    this._gridAxisOfDay = ttb.gridAxisOfDay;
    this._gridAxisOfTime = ttb.gridAxisOfTime;
    this._gridAxisOfCustom = ttb.gridAxisOfCustom;
    this._axisDay = ttb.axisDay;
    this._axisTime = ttb.axisTime;
    this._axisCustom = ttb.axisCustom;
    this._gridDataList = TimetableGridDataList();
    notifyListeners();
  }

  void updateAxisTimeValue({
    @required Time prev,
    @required Time next,
  }) {
    TimetableGridDataList tmpGridDataList =
        TimetableGridDataList.from(this.gridDataList);

    for (TimetableGridData gridData in tmpGridDataList.value) {
      // find coord to be replaced
      if (gridData.coord.time == prev) {
        TimetableGridData newGridData = TimetableGridData.from(gridData);
        newGridData.coord.time = next;

        this.gridDataList.pop(gridData);
        this.gridDataList.push(newGridData);
      }
    }
    this._hasChanges = true;
    notifyListeners();
  }

  void updateAxisCustomValue({
    @required String prev,
    @required String next,
  }) {
    TimetableGridDataList tmpGridDataList =
        TimetableGridDataList.from(this.gridDataList);

    for (TimetableGridData gridData in tmpGridDataList.value) {
      if (gridData.coord.custom == prev) {
        TimetableGridData tmpGridData = TimetableGridData.from(gridData);
        tmpGridData.coord.custom = next;

        this.gridDataList.pop(gridData);
        this.gridDataList.push(tmpGridData);
      }
    }
    this._hasChanges = true;
    notifyListeners();
  }

  void validateGridDataList({
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
          timetableTimes = generateTimes(
            months: List.generate(
              Month.values.length,
              (index) => Month.values[index],
            ),
            weekdays: [gridData.coord.day],
            time: gridData.coord.time,
            startDate: this.startDate,
            endDate: this.endDate,
          );

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
    this._hasChanges = true;
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

// convert from [EditTimetable] to Firestore's [Map<String, dynamic>] format
Map<String, dynamic> firestoreMapFromEditTimetable(EditTimetable editTtb) {
  Map<String, dynamic> firestoreMap = {};

  // convert startDate and endDate
  firestoreMap['startDate'] = Timestamp.fromDate(editTtb.startDate);
  firestoreMap['endDate'] = Timestamp.fromDate(editTtb.endDate);

  // convert gridAxisTypes
  if (editTtb.gridAxisOfDay == null ||
      editTtb.gridAxisOfTime == null ||
      editTtb.gridAxisOfCustom == null) {
    firestoreMap['gridAxisOfDay'] = GridAxis.x.index;
    firestoreMap['gridAxisOfTime'] = GridAxis.y.index;
    firestoreMap['gridAxisOfCustom'] = GridAxis.z.index;
  } else {
    List<GridAxis> gridAxisTypes = [
      editTtb.gridAxisOfDay,
      editTtb.gridAxisOfTime,
      editTtb.gridAxisOfCustom,
    ];

    if (gridAxisTypes.contains(GridAxis.x) &&
        gridAxisTypes.contains(GridAxis.y) &&
        gridAxisTypes.contains(GridAxis.z)) {
      firestoreMap['gridAxisOfDay'] = editTtb.gridAxisOfDay.index;
      firestoreMap['gridAxisOfTime'] = editTtb.gridAxisOfTime.index;
      firestoreMap['gridAxisOfCustom'] = editTtb.gridAxisOfCustom.index;
    } else {
      firestoreMap['gridAxisOfDay'] = GridAxis.x.index;
      firestoreMap['gridAxisOfTime'] = GridAxis.y.index;
      firestoreMap['gridAxisOfCustom'] = GridAxis.z.index;
    }
  }

  // convert axisDay
  if (editTtb.axisDay != null) {
    List<int> axisDaysInt = [];
    editTtb.axisDay.forEach((weekday) => axisDaysInt.add(weekday.index));
    axisDaysInt.sort((a, b) => a.compareTo(b));
    firestoreMap['axisDay'] = axisDaysInt;
  }

  // convert axisTime
  if (editTtb.axisTime != null) {
    List<Map<String, Timestamp>> axisTimesTimestamps = [];
    editTtb.axisTime.forEach((time) {
      axisTimesTimestamps.add({
        'startTime': Timestamp.fromDate(time.startTime),
        'endTime': Timestamp.fromDate(time.endTime),
      });
    });
    axisTimesTimestamps
        .sort((a, b) => a['startTime'].compareTo(b['startTime']));
    firestoreMap['axisTime'] = axisTimesTimestamps;
  }

  // convert axisCustom
  if (editTtb.axisCustom != null) {
    firestoreMap['axisCustom'] = editTtb.axisCustom;
  }

  // convert gridDataList
  if (editTtb.gridDataList != null) {
    List<Map<String, dynamic>> gridDataList = [];

    for (TimetableGridData gridData in editTtb.gridDataList.value) {
      if (editTtb.axisDay.contains(gridData.coord.day) &&
          editTtb.axisTime.contains(gridData.coord.time) &&
          editTtb.axisCustom.contains(gridData.coord.custom)) {
        // convert coords
        Map<String, dynamic> coord = {
          'day': gridData.coord.day.index,
          'time': {
            'startTime': Timestamp.fromDate(gridData.coord.time.startTime),
            'endTime': Timestamp.fromDate(gridData.coord.time.endTime),
          },
          'custom': gridData.coord.custom,
        };

        // convert subject
        Map subject = {
          'docId': gridData.dragData.subject.docId,
          'display': gridData.dragData.subject.display,
        };

        // convert member
        Map member = {
          'docId': gridData.dragData.member.docId,
          'display': gridData.dragData.member.display,
        };

        // convert available
        bool available = gridData.available;
        bool ignore = gridData.ignore;

        // add to list
        gridDataList.add({
          'coord': coord,
          'subject': subject,
          'member': member,
          'available': available,
          'ignore': ignore,
        });
      }
    }

    firestoreMap['gridDataList'] = gridDataList;
  }

  // return final map in firestore format
  return firestoreMap;
}
