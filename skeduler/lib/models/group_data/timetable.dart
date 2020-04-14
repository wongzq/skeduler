import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skeduler/models/group_data/time.dart';

class Timetable {
  /// Properties
  String _id;
  DateTime _startDate;
  DateTime _endDate;

  List<Weekday> _axisDays = [];
  List<Time> _axisTimes = [];
  List<String> _axisCustom = [];

  /// Constructor
  Timetable({
    @required String id,
    Timestamp startDate,
    Timestamp endDate,
    List<dynamic> axisDays,
    List<dynamic> axisTimes,
    List<dynamic> axisCustom,
  }) {
    _id = id;
    _startDate =
        DateTime.fromMillisecondsSinceEpoch(startDate.millisecondsSinceEpoch);
    _endDate =
        DateTime.fromMillisecondsSinceEpoch(endDate.millisecondsSinceEpoch);

    axisDays.forEach((val) {
      _axisDays.add(Weekday.values[val]);
    });

    axisTimes.forEach((val) {
      _axisTimes.add(Time(
        DateTime.fromMillisecondsSinceEpoch(
            val['startTime'].millisecondsSinceEpoch),
        DateTime.fromMillisecondsSinceEpoch(
            val['endTime'].millisecondsSinceEpoch),
      ));
    });

    axisCustom.forEach((val) {
      _axisCustom.add(val);
    });
  }

  /// getter methods
  String get id => _id;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  List<Weekday> get axisDays => _axisDays;
  List<Time> get axisTimes => _axisTimes;
  List<String> get axisCustom => _axisCustom;
}

class TempTimetable {
  /// Properties
  String _id;
  DateTime _startDate;
  DateTime _endDate;

  List<Weekday> _axisDays = [];
  List<Time> _axisTimes = [];
  List<String> _axisCustom = [];

  TempTimetable({
    String id,
    DateTime startDate,
    DateTime endDate,
    List<Weekday> axisDays,
    List<Time> axisTimes,
    List<String> axisCustom,
    Timetable timetable,
  })  : _id = id,
        _startDate = startDate,
        _endDate = endDate,
        _axisDays = axisDays,
        _axisTimes = axisTimes,
        _axisCustom = axisCustom {
    if (timetable != null) {
      _id = timetable.id;
      _startDate = timetable.startDate;
      _endDate = timetable.endDate;
      _axisDays = timetable.axisDays;
      _axisTimes = timetable.axisTimes;
      _axisCustom = timetable.axisCustom;
    }
  }

  /// getter methods
  String get id => this._id;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  List<Weekday> get axisDays => this._axisDays;
  List<Time> get axisTimes => this._axisTimes;
  List<String> get axisCustom => this._axisCustom;

  /// setter methods
  set id(String id) => this._id = id;
  set startDate(DateTime startDate) => this._startDate = startDate;
  set endDate(DateTime endDate) => this._endDate = endDate;
  set axisDays(List<Weekday> axisDays) => this._axisDays = axisDays;
  set axisTimes(List<Time> axisTimes) => this._axisTimes = axisTimes;
  set axisCustom(List<String> axisCustom) => this._axisCustom = axisCustom;
}

/// convert from [TempTimetable] to Firestore's [Map<String, dynamic>] format
Map<String, dynamic> firestoreMapFromTimetable(TempTimetable tempTimetable) {
  Map<String, dynamic> firestoreMap = {};

  /// convert startDate and endDate
  firestoreMap['startDate'] = Timestamp.fromMillisecondsSinceEpoch(
      tempTimetable.startDate.millisecondsSinceEpoch);
  firestoreMap['endDate'] = Timestamp.fromMillisecondsSinceEpoch(
      tempTimetable.endDate.millisecondsSinceEpoch);

  /// convert axisDays
  if (tempTimetable.axisDays != null) {
    List<int> axisDaysInt = [];
    tempTimetable.axisDays.forEach((weekday) => axisDaysInt.add(weekday.index));
    axisDaysInt.sort((a, b) => a.compareTo(b));
    firestoreMap['axisDays'] = axisDaysInt;
  }

  /// convert axisTimes
  if (tempTimetable.axisTimes != null) {
    List<Map<String, Timestamp>> axisTimesTimestamps = [];
    tempTimetable.axisTimes.forEach((time) {
      axisTimesTimestamps.add({
        'startTime': Timestamp.fromMillisecondsSinceEpoch(
            time.startTime.millisecondsSinceEpoch),
        'endTime': Timestamp.fromMillisecondsSinceEpoch(
            time.endTime.millisecondsSinceEpoch),
      });
    });
    axisTimesTimestamps
        .sort((a, b) => a['startTime'].compareTo(b['startTime']));
    firestoreMap['axisTimes'] = axisTimesTimestamps;
  }

  /// return final map in firestore format
  return firestoreMap;
}

/// auxiliary function to check if all [Time] in [List<Time>] is consecutive with no conflicts of time
bool isConsecutiveTimes(List<Time> times) {
  bool isConsecutive = true;

  /// sort the area in terms of startTime
  times.sort((a, b) {
    return a.startTime.millisecondsSinceEpoch
        .compareTo(b.startTime.millisecondsSinceEpoch);
  });

  /// loop through the array to find any conflict
  for (int i = 0; i < times.length; i++) {
    print('i ' + i.toString());
    print(times[i].startTime);
    print(times[i].endTime);

    if (i != 0) {
      /// if conflict is found, returns [hasNoConflict] as [false]
      if (!(times[i - 1].startTime.isBefore(times[i].startTime) &&
          times[i - 1].endTime.isBefore(times[i].endTime) &&
          (times[i - 1].endTime.isBefore(times[i].startTime) ||
              times[i - 1].endTime.isAtSameMomentAs(times[i].startTime)))) {
        print('conflict found');
        isConsecutive = false;
        break;
      }
    }
  }

  return isConsecutive;
}

/// auxiliary function to check if all [Timetable] in [List<Timetable>] is consecutive with no conflicts of date
bool isConsecutiveTimetables(List<Timetable> timetables) {
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
      if (!(timetables[i - 1].startDate.isBefore(timetables[i].startDate) &&
          timetables[i - 1].endDate.isBefore(timetables[i].endDate) &&
          (timetables[i - 1].endDate.isBefore(timetables[i].startDate) ||
              timetables[i - 1]
                  .endDate
                  .isAtSameMomentAs(timetables[i].startDate)))) {
        isConsecutive = false;
        break;
      }
    }
  }

  return isConsecutive;
}
