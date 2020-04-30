import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/group_data/time.dart';

// --------------------------------------------------------------------------------
// TimetableMetadata class
// --------------------------------------------------------------------------------

class TimetableMetadata {
  // properties
  String id;
  Timestamp startDate;
  Timestamp endDate;

  TimetableMetadata({
    this.id,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> get asMap {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
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

  List<Weekday> _axisDay = [];
  List<Time> _axisTime = [];
  List<String> _axisCustom = [];

  TimetableGridDataList _gridDataList = TimetableGridDataList();

  // constructors
  Timetable({
    @required String docId,
    Timestamp startDate,
    Timestamp endDate,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableGridDataList gridDataList,
  }) {
    // documentID
    _docId = docId;

    // timetable start date
    if (startDate != null)
      _startDate =
          DateTime.fromMillisecondsSinceEpoch(startDate.millisecondsSinceEpoch);

    // timetable end date
    if (endDate != null)
      _endDate =
          DateTime.fromMillisecondsSinceEpoch(endDate.millisecondsSinceEpoch);

    // timetable days axis
    if (axisDay != null) _axisDay = List<Weekday>.from(axisDay ?? []);

    // timetable times axis
    if (axisTime != null) _axisTime = List<Time>.from(axisTime ?? []);

    // timetable custom axis
    if (axisCustom != null) _axisCustom = List<String>.from(axisCustom ?? []);

    if (gridDataList != null)
      _gridDataList =
          TimetableGridDataList.from(gridDataList ?? TimetableGridDataList());
  }

  // getter methods
  String get docId => _docId;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  List<Weekday> get axisDay => _axisDay;
  List<Time> get axisTime => _axisTime;
  List<String> get axisCustom => _axisCustom;
  TimetableGridDataList get gridDataList => _gridDataList;

  // getter as [List<String>]
  List<String> get axisDayStr =>
      List.generate(_axisDay.length, (index) => getWeekdayStr(_axisDay[index]));
  List<String> get axisDayShortStr => List.generate(
      _axisDay.length, (index) => getWeekdayShortStr(_axisDay[index]));
  List<String> get axisTimeStr =>
      List.generate(_axisTime.length, (index) => getTimeStr(_axisTime[index]));

  bool isValid() {
    return this._docId != null &&
            this._docId.trim() != '' &&
            this._startDate != null &&
            this._endDate != null
        ? true
        : false;
  }
}

// --------------------------------------------------------------------------------
// EditTimetable class
// --------------------------------------------------------------------------------

class EditTimetable extends ChangeNotifier {
  // properties
  String _docId;
  DateTime _startDate;
  DateTime _endDate;

  List<Weekday> _axisDay;
  List<Time> _axisTime;
  List<String> _axisCustom;

  TimetableGridDataList _gridDataList;

  // constructors
  EditTimetable({
    String docId,
    DateTime startDate,
    DateTime endDate,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableGridDataList gridDataList,
  })  : _docId = docId,
        _startDate = startDate,
        _endDate = endDate,
        _axisDay = List<Weekday>.from(axisDay ?? []),
        _axisTime = List<Time>.from(axisTime ?? []),
        _axisCustom = List<String>.from(axisCustom ?? []),
        _gridDataList =
            TimetableGridDataList.from(gridDataList ?? TimetableGridDataList());

  EditTimetable.fromTimetable(Timetable timetable)
      : this(
          docId: timetable.docId,
          startDate: timetable.startDate,
          endDate: timetable.endDate,
          axisDay: timetable.axisDay,
          axisTime: timetable.axisTime,
          axisCustom: timetable.axisCustom,
          gridDataList: timetable.gridDataList,
        );

  EditTimetable.copy(EditTimetable timetable)
      : this(
          docId: timetable.docId,
          startDate: timetable.startDate,
          endDate: timetable.endDate,
          axisDay: timetable.axisDay,
          axisTime: timetable.axisTime,
          axisCustom: timetable.axisCustom,
          gridDataList: timetable.gridDataList,
        );

  // getter methods
  String get docId => this._docId;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  List<Weekday> get axisDay => this._axisDay;
  List<Time> get axisTime => this._axisTime;
  List<String> get axisCustom => this._axisCustom;
  TimetableGridDataList get gridDataList => this._gridDataList;

  TimetableMetadata get metadata => TimetableMetadata(
        id: this._docId,
        startDate: Timestamp.fromDate(this._startDate),
        endDate: Timestamp.fromDate(this._endDate),
      );

  // getter as [List<String>]
  List<String> get axisDayStr =>
      List.generate(_axisDay.length, (index) => getWeekdayStr(_axisDay[index]));
  List<String> get axisDayShortStr => List.generate(
      _axisDay.length, (index) => getWeekdayShortStr(_axisDay[index]));
  List<String> get axisTimeStr =>
      List.generate(_axisTime.length, (index) => getTimeStr(_axisTime[index]));

  // setter methods
  set docId(String id) {
    this._docId = id;
    notifyListeners();
  }

  set startDate(DateTime startDate) {
    this._startDate = startDate;
    notifyListeners();
  }

  set endDate(DateTime endDate) {
    this._endDate = endDate;
    notifyListeners();
  }

  set axisDay(List<Weekday> axisDay) {
    this._axisDay = axisDay;
    this._axisDay.sort((a, b) => a.index.compareTo(b.index));
    notifyListeners();
  }

  set axisTime(List<Time> axisTime) {
    this._axisTime = axisTime;
    this._axisTime.sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();
  }

  set axisCustom(List<String> axisCustom) {
    this._axisCustom = axisCustom;
    notifyListeners();
  }

  set gridDataList(TimetableGridDataList gridDataList) {
    this._gridDataList = gridDataList;
    notifyListeners();
  }

  bool isValid() {
    return this._docId != null &&
            this._docId.trim() != '' &&
            this._startDate != null &&
            this._endDate != null
        ? true
        : false;
  }

  void updateTimetableSettings({
    String docId,
    DateTime startDate,
    DateTime endDate,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
  }) {
    this.docId = docId ?? this.docId;
    this.startDate = startDate ?? this.startDate;
    this.endDate = endDate ?? this.endDate;
    this.axisDay = axisDay ?? this.axisDay;
    this.axisTime = axisTime ?? this.axisTime;
    this.axisCustom = axisCustom ?? this.axisCustom;
    notifyListeners();
  }
}

// --------------------------------------------------------------------------------
// EditTimetableStatus class for Provider
// --------------------------------------------------------------------------------

class TimetableStatus extends ChangeNotifier {
  // current
  Timetable curr;

  // permanent
  EditTimetable edit;

  // temporary
  EditTimetable editTemp;
}

// auxiliary function to check if all [Timetable] in [List<Timetable>] is consecutive with no conflicts of date
bool isConsecutiveTimetables(List<TimetableMetadata> timetables) {
  bool isConsecutive = true;

  // sort the area in terms of startDate
  timetables.sort((a, b) {
    return a.startDate.millisecondsSinceEpoch
        .compareTo(b.startDate.millisecondsSinceEpoch);
  });

  // loop through the array to find any conflict
  for (int i = 0; i < timetables.length; i++) {
    if (i != 0) {
      // if conflict is found, returns [hasNoConflict] as [false]
      if (!(timetables[i - 1]
              .startDate
              .toDate()
              .isBefore(timetables[i].startDate.toDate()) &&
          timetables[i - 1]
              .endDate
              .toDate()
              .isBefore(timetables[i].endDate.toDate()) &&
          (timetables[i - 1]
                  .endDate
                  .toDate()
                  .isBefore(timetables[i].startDate.toDate()) ||
              timetables[i - 1]
                  .endDate
                  .toDate()
                  .isAtSameMomentAs(timetables[i].startDate.toDate())))) {
        isConsecutive = false;
        break;
      }
    }
  }

  return isConsecutive;
}

// --------------------------------------------------------------------------------
// Auxiliary functions
// --------------------------------------------------------------------------------

// convert from [EditTimetable] to Firestore's [Map<String, dynamic>] format
Map<String, dynamic> firestoreMapFromTimetable(EditTimetable editTtb) {
  Map<String, dynamic> firestoreMap = {};

  // convert startDate and endDate
  firestoreMap['startDate'] = Timestamp.fromDate(editTtb.startDate);
  firestoreMap['endDate'] = Timestamp.fromDate(editTtb.endDate);

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

    editTtb.gridDataList.value.forEach((gridData) {
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
        String subject = gridData.dragData.subject.display;

        // convert member
        String member = gridData.dragData.member.display;

        // add to list
        gridDataList.add({
          'coord': coord,
          'subject': subject,
          'member': member,
        });
      }
    });

    firestoreMap['gridDataList'] = gridDataList;
  }

  // return final map in firestore format
  return firestoreMap;
}
