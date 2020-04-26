import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid.dart';

import 'member.dart';

////////////////////////////////////////////////////////////////////////////////
/// TimetableMetadata class
////////////////////////////////////////////////////////////////////////////////

class TimetableMetadata {
  /// properties
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

////////////////////////////////////////////////////////////////////////////////
/// TimetableDisplayInfo class for Provider
////////////////////////////////////////////////////////////////////////////////

class EditModeBool extends ChangeNotifier {
  bool _value;

  EditModeBool({bool value = false}) : _value = value;

  bool get value => this._value;

  set value(bool newValue) {
    _value = newValue;
    notifyListeners();
  }
}

class BinVisibleBool extends ChangeNotifier {
  bool _value;

  BinVisibleBool({bool value = false}) : _value = value;

  bool get value => this._value;

  set value(bool newValue) {
    _value = newValue;
    notifyListeners();
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Timetable class
////////////////////////////////////////////////////////////////////////////////

class Timetable {
  /// properties
  String _docId;
  DateTime _startDate;
  DateTime _endDate;

  List<Weekday> _axisDays = [];
  List<Time> _axisTimes = [];
  List<String> _axisCustom = [];

  /// constructors
  Timetable({
    @required String docId,
    Timestamp startDate,
    Timestamp endDate,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
  }) {
    /// documentID
    _docId = docId;

    /// timetable start date
    if (startDate != null)
      _startDate =
          DateTime.fromMillisecondsSinceEpoch(startDate.millisecondsSinceEpoch);

    /// timetable end date
    if (endDate != null)
      _endDate =
          DateTime.fromMillisecondsSinceEpoch(endDate.millisecondsSinceEpoch);

    /// timetable days axis
    if (axisDay != null) _axisDays = List<Weekday>.from(axisDay ?? []);

    /// timetable times axis
    if (axisTime != null) _axisTimes = List<Time>.from(axisTime ?? []);

    /// timetable custom axis
    if (axisCustom != null) _axisCustom = List<String>.from(axisCustom ?? []);
  }

  Timetable.fromEditTimetable(EditTimetable editTtb)
      : this(
          docId: editTtb.docId,
          startDate: Timestamp.fromDate(editTtb.startDate),
          endDate: Timestamp.fromDate(editTtb.endDate),
          axisDay: editTtb.axisDay,
          axisTime: editTtb.axisTime,
          axisCustom: editTtb.axisCustom,
        );

  /// getter methods
  String get docId => _docId;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  List<Weekday> get axisDay => _axisDays;
  List<Time> get axisTime => _axisTimes;
  List<String> get axisCustom => _axisCustom;

  /// getter as [List<String>]
  List<String> get axisDayStr => List.generate(
      _axisDays.length, (index) => getWeekdayStr(_axisDays[index]));
  List<String> get axisDayShortStr => List.generate(
      _axisDays.length, (index) => getWeekdayShortStr(_axisDays[index]));
  List<String> get axisTimeStr => List.generate(
      _axisTimes.length, (index) => getTimeStr(_axisTimes[index]));

  bool isValid() {
    return this._docId != null &&
            this._docId.trim() != '' &&
            this._startDate != null &&
            this._endDate != null
        ? true
        : false;
  }
}

////////////////////////////////////////////////////////////////////////////////
/// EditTimetable class
////////////////////////////////////////////////////////////////////////////////

class EditTimetable {
  /// properties
  String _docId;
  DateTime _startDate;
  DateTime _endDate;

  List<Weekday> _axisDays;
  List<Time> _axisTimes;
  List<String> _axisCustom;

  /// constructors
  EditTimetable({
    String docId,
    DateTime startDate,
    DateTime endDate,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
  })  : _docId = docId,
        _startDate = startDate,
        _endDate = endDate,
        _axisDays = List<Weekday>.from(axisDay ?? []),
        _axisTimes = List<Time>.from(axisTime ?? []),
        _axisCustom = List<String>.from(axisCustom ?? []);

  EditTimetable.fromTimetable(Timetable timetable)
      : this(
          docId: timetable.docId,
          startDate: timetable.startDate,
          endDate: timetable.endDate,
          axisDay: timetable.axisDay,
          axisTime: timetable.axisTime,
          axisCustom: timetable.axisCustom,
        );

  EditTimetable.copy(EditTimetable timetable)
      : this(
          docId: timetable.docId,
          startDate: timetable.startDate,
          endDate: timetable.endDate,
          axisDay: timetable.axisDay,
          axisTime: timetable.axisTime,
          axisCustom: timetable.axisCustom,
        );

  /// getter methods
  String get docId => this._docId;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  List<Weekday> get axisDay => this._axisDays;
  List<Time> get axisTime => this._axisTimes;
  List<String> get axisCustom => this._axisCustom;
  TimetableMetadata get metadata => TimetableMetadata(
        id: this._docId,
        startDate: Timestamp.fromDate(this._startDate),
        endDate: Timestamp.fromDate(this._endDate),
      );

  /// setter methods
  set docId(String id) => this._docId = id;
  set startDate(DateTime startDate) => this._startDate = startDate;
  set endDate(DateTime endDate) => this._endDate = endDate;
  set axisDay(List<Weekday> axisDay) => this._axisDays = axisDay;
  set axisTime(List<Time> axisTime) => this._axisTimes = axisTime;
  set axisCustom(List<String> axisCustom) => this._axisCustom = axisCustom;

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
  }
}

////////////////////////////////////////////////////////////////////////////////
/// EditTimetableStatus class
////////////////////////////////////////////////////////////////////////////////

class EditTimetableStatus {
  /// permanent
  EditTimetable perm;

  /// temporary
  EditTimetable temp;
}

////////////////////////////////////////////////////////////////////////////////
/// TimetableGrid related classes
////////////////////////////////////////////////////////////////////////////////

class TimetableCoord {
  Weekday weekday;
  Time time;
  String custom;

  bool isSameAs(TimetableCoord coord) {
    return this.weekday == coord.weekday &&
            this.time.startTime == coord.time.startTime &&
            this.time.endTime == coord.time.endTime &&
            this.custom == coord.custom
        ? true
        : false;
  }
}

class TimetableGridData {
  TimetableCoord _coord;
  String _subject;
  Member _member;

  TimetableGridData({
    TimetableCoord coord,
    String subject,
    Member member,
  })  : _coord = coord,
        _subject = subject,
        _member = member;

  TimetableCoord get coord => this._coord;
  String get subject => this._subject;
  Member get member => this._member;

  set coord(TimetableCoord val) => this._coord = val;
  set subject(String val) => this._subject = val;
  set member(Member val) => this._member = val;

  bool hasSameCoordAs(TimetableGridData gridData) {
    return gridData._coord == null
        ? true
        : this._coord.isSameAs(gridData.coord);
  }
}

class TimetableGridDataList extends ChangeNotifier {
  List<TimetableGridData> _value;

  TimetableGridDataList({dataList}) : _value = dataList ?? [];

  List<TimetableGridData> get value => List.unmodifiable(this._value);

  void add(TimetableGridData newGridData) {
    TimetableGridData toRemove;

    for (TimetableGridData gridData in this._value) {
      if (gridData.hasSameCoordAs(newGridData)) {
        toRemove = gridData;
        break;
      }
    }

    if (toRemove != null) {
      this._value.remove(toRemove);
    }

    this._value.add(newGridData);

    notifyListeners();
  }

  bool remove(TimetableGridData newGridData) {
    TimetableGridData toRemove;

    for (TimetableGridData gridData in this._value) {
      if (gridData.hasSameCoordAs(newGridData)) {
        toRemove = gridData;
        break;
      }
    }

    if (toRemove != null) {
      this._value.remove(toRemove);
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Auxiliary functions
////////////////////////////////////////////////////////////////////////////////

/// convert from [EditTimetable] to Firestore's [Map<String, dynamic>] format
Map<String, dynamic> firestoreMapFromTimetable(EditTimetable editTtb) {
  Map<String, dynamic> firestoreMap = {};

  /// convert startDate and endDate
  firestoreMap['startDate'] = Timestamp.fromDate(editTtb.startDate);
  firestoreMap['endDate'] = Timestamp.fromDate(editTtb.endDate);

  /// convert axisDay
  if (editTtb.axisDay != null) {
    List<int> axisDaysInt = [];
    editTtb.axisDay.forEach((weekday) => axisDaysInt.add(weekday.index));
    axisDaysInt.sort((a, b) => a.compareTo(b));
    firestoreMap['axisDay'] = axisDaysInt;
  }

  /// convert axisTime
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

  /// convert axisCustom
  if (editTtb.axisCustom != null) {
    firestoreMap['axisCustom'] = editTtb.axisCustom;
  }

  /// return final map in firestore format
  return firestoreMap;
}

/// auxiliary function to check if all [Timetable] in [List<Timetable>] is consecutive with no conflicts of date
bool isConsecutiveTimetables(List<TimetableMetadata> timetables) {
  bool isConsecutive = true;

  /// sort the area in terms of startDate
  timetables.sort((a, b) {
    return a.startDate.millisecondsSinceEpoch
        .compareTo(b.startDate.millisecondsSinceEpoch);
  });

  /// loop through the array to find any conflict
  for (int i = 0; i < timetables.length; i++) {
    if (i != 0) {
      /// if conflict is found, returns [hasNoConflict] as [false]
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
