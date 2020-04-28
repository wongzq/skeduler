import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:quiver/core.dart';
import 'package:skeduler/models/group_data/time.dart';

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
/// Timetable class
////////////////////////////////////////////////////////////////////////////////

class Timetable {
  /// properties
  String _docId;
  DateTime _startDate;
  DateTime _endDate;

  List<Weekday> _axisDay = [];
  List<Time> _axisTime = [];
  List<String> _axisCustom = [];

  TimetableSlotDataList _slotDataList = TimetableSlotDataList();

  /// constructors
  Timetable({
    @required String docId,
    Timestamp startDate,
    Timestamp endDate,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableSlotDataList slotDataList,
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
    if (axisDay != null) _axisDay = List<Weekday>.from(axisDay ?? []);

    /// timetable times axis
    if (axisTime != null) _axisTime = List<Time>.from(axisTime ?? []);

    /// timetable custom axis
    if (axisCustom != null) _axisCustom = List<String>.from(axisCustom ?? []);

    if (slotDataList != null)
      _slotDataList =
          TimetableSlotDataList.from(slotDataList ?? TimetableSlotDataList());
  }

  /// getter methods
  String get docId => _docId;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  List<Weekday> get axisDay => _axisDay;
  List<Time> get axisTime => _axisTime;
  List<String> get axisCustom => _axisCustom;
  TimetableSlotDataList get slotDataList => _slotDataList;

  /// getter as [List<String>]
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

////////////////////////////////////////////////////////////////////////////////
/// EditTimetable class
////////////////////////////////////////////////////////////////////////////////

class EditTimetable extends ChangeNotifier {
  /// properties
  String _docId;
  DateTime _startDate;
  DateTime _endDate;

  List<Weekday> _axisDay;
  List<Time> _axisTime;
  List<String> _axisCustom;

  TimetableSlotDataList _slotDataList;

  /// constructors
  EditTimetable({
    String docId,
    DateTime startDate,
    DateTime endDate,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableSlotDataList slotDataList,
  })  : _docId = docId,
        _startDate = startDate,
        _endDate = endDate,
        _axisDay = List<Weekday>.from(axisDay ?? []),
        _axisTime = List<Time>.from(axisTime ?? []),
        _axisCustom = List<String>.from(axisCustom ?? []),
        _slotDataList =
            TimetableSlotDataList.from(slotDataList ?? TimetableSlotDataList());

  EditTimetable.fromTimetable(Timetable timetable)
      : this(
          docId: timetable.docId,
          startDate: timetable.startDate,
          endDate: timetable.endDate,
          axisDay: timetable.axisDay,
          axisTime: timetable.axisTime,
          axisCustom: timetable.axisCustom,
          slotDataList: timetable.slotDataList,
        );

  EditTimetable.copy(EditTimetable timetable)
      : this(
          docId: timetable.docId,
          startDate: timetable.startDate,
          endDate: timetable.endDate,
          axisDay: timetable.axisDay,
          axisTime: timetable.axisTime,
          axisCustom: timetable.axisCustom,
          slotDataList: timetable.slotDataList,
        );

  /// getter methods
  String get docId => this._docId;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  List<Weekday> get axisDay => this._axisDay;
  List<Time> get axisTime => this._axisTime;
  List<String> get axisCustom => this._axisCustom;
  TimetableSlotDataList get slotDataList => this._slotDataList;

  TimetableMetadata get metadata => TimetableMetadata(
        id: this._docId,
        startDate: Timestamp.fromDate(this._startDate),
        endDate: Timestamp.fromDate(this._endDate),
      );

  /// getter as [List<String>]
  List<String> get axisDayStr =>
      List.generate(_axisDay.length, (index) => getWeekdayStr(_axisDay[index]));
  List<String> get axisDayShortStr => List.generate(
      _axisDay.length, (index) => getWeekdayShortStr(_axisDay[index]));
  List<String> get axisTimeStr =>
      List.generate(_axisTime.length, (index) => getTimeStr(_axisTime[index]));

  /// setter methods
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

  set slotDataList(TimetableSlotDataList slotDataList) {
    this._slotDataList = slotDataList;
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

////////////////////////////////////////////////////////////////////////////////
/// EditTimetableStatus class for Provider
////////////////////////////////////////////////////////////////////////////////

class TimetableStatus extends ChangeNotifier {
  /// current
  Timetable curr;

  /// permanent
  EditTimetable perm;

  /// temporary
  EditTimetable temp;
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
/// TimetableAxis related classes
////////////////////////////////////////////////////////////////////////////////

enum TimetableAxisType { day, time, custom }

String getAxisTypeStr(TimetableAxisType axisType) {
  switch (axisType) {
    case TimetableAxisType.day:
      return 'Day';
      break;
    case TimetableAxisType.time:
      return 'Time';
      break;
    case TimetableAxisType.custom:
      return 'Custom';
      break;
    default:
      return '';
      break;
  }
}

enum GridAxisType { x, y, z }

class GridAxisLayout {
  TimetableAxisType x;
  TimetableAxisType y;
  TimetableAxisType z;

  TimetableAxisType timetableAxis(GridAxisType gridAxisType) {
    switch (gridAxisType) {
      case GridAxisType.x:
        return x;
        break;
      case GridAxisType.y:
        return y;
        break;
      case GridAxisType.z:
        return z;
        break;
      default:
        return null;
        break;
    }
  }
}

class TimetableAxis {
  TimetableAxisType _ttbAxisType;
  List<dynamic> _list;
  List<String> _listStr;

  TimetableAxis({
    @required TimetableAxisType type,
    List<dynamic> list,
    List<String> listStr,
  })  : _ttbAxisType = type,
        _list = list ?? [],
        _listStr = listStr ?? [];

  TimetableAxisType get type => this._ttbAxisType;
  List get list => () {
        switch (this._ttbAxisType) {
          case TimetableAxisType.day:
            return this._list;
            break;
          case TimetableAxisType.time:
            return this._list;
            break;
          case TimetableAxisType.custom:
            return this._list;
            break;
          default:
            return null;
            break;
        }
      }();
  List<String> get listStr => this._listStr;

  set type(TimetableAxisType type) => this._ttbAxisType = type;
}

class TimetableAxes extends ChangeNotifier {
  /// properties
  TimetableAxis _x;
  TimetableAxis _y;
  TimetableAxis _z;
  bool _empty;

  /// constructors
  TimetableAxes.empty() : _empty = true;

  TimetableAxes({TimetableAxis x, TimetableAxis y, TimetableAxis z}) {
    if (x == null) x = TimetableAxis(type: TimetableAxisType.day);
    if (y == null) y = TimetableAxis(type: TimetableAxisType.time);
    if (z == null) z = TimetableAxis(type: TimetableAxisType.custom);

    if (!updateAxes(x: x, y: y, z: z)) {
      this._x = TimetableAxis(type: TimetableAxisType.day);
      this._y = TimetableAxis(type: TimetableAxisType.time);
      this._z = TimetableAxis(type: TimetableAxisType.custom);
    }

    _empty = false;

    notifyListeners();
  }

  /// getter methods
  bool get isEmpty => this._empty;
  TimetableAxisType get xType => this._x.type;
  TimetableAxisType get yType => this._y.type;
  TimetableAxisType get zType => this._z.type;
  List get xList => this._x.list;
  List get yList => this._y.list;
  List get zList => this._z.list;
  List<String> get xListStr => this._x.listStr;
  List<String> get yListStr => this._y.listStr;
  List<String> get zListStr => this._z.listStr;

  TimetableAxis get axisDay => _getAxisOfType(TimetableAxisType.day);
  TimetableAxis get axisTime => _getAxisOfType(TimetableAxisType.time);
  TimetableAxis get axisCustom => _getAxisOfType(TimetableAxisType.custom);

  /// setter methods
  set xType(TimetableAxisType newX) {
    _changeAxisType(this._x.type, newX);
    notifyListeners();
  }

  set yType(TimetableAxisType newY) {
    _changeAxisType(this._y.type, newY);
    notifyListeners();
  }

  set zType(TimetableAxisType newZ) {
    _changeAxisType(this._z.type, newZ);
    notifyListeners();
  }

  /// auxiliary methods
  bool updateAxes({TimetableAxis x, TimetableAxis y, TimetableAxis z}) {
    x = x ?? this._x;
    y = y ?? this._y;
    z = z ?? this._z;

    List<TimetableAxisType> axesTypes = [x.type, y.type, z.type];

    if (axesTypes.contains(TimetableAxisType.day) &&
        axesTypes.contains(TimetableAxisType.time) &&
        axesTypes.contains(TimetableAxisType.custom)) {
      this._x = x;
      this._y = y;
      this._z = z;

      _empty = false;
      return true;
    } else {
      return false;
    }
  }

  void clearAxes() {
    this._x = null;
    this._y = null;
    this._z = null;

    _empty = true;
  }

  TimetableAxis _getAxisOfType(TimetableAxisType axisType) {
    return this._x.type == axisType
        ? this._x
        : this._y.type == axisType
            ? this._y
            : this._z.type == axisType ? this._z : null;
  }

  void _changeAxisType(
      TimetableAxisType thisAxisType, TimetableAxisType newAxisType) {
    if (newAxisType != thisAxisType) {
      bool success = false;
      if (!success && thisAxisType != this._x.type) {
        success = _checkAgainstAxisOfType(
            thisAxisType: thisAxisType,
            newAxisType: newAxisType,
            checkAxis: this._x);
      }
      if (!success && thisAxisType != this._y.type) {
        success = _checkAgainstAxisOfType(
          thisAxisType: thisAxisType,
          newAxisType: newAxisType,
          checkAxis: this._y,
        );
      }
      if (!success && thisAxisType != this._z.type) {
        success = _checkAgainstAxisOfType(
          thisAxisType: thisAxisType,
          newAxisType: newAxisType,
          checkAxis: this._z,
        );
      }
    }
  }

  bool _checkAgainstAxisOfType({
    @required TimetableAxisType thisAxisType,
    @required TimetableAxisType newAxisType,
    @required TimetableAxis checkAxis,
  }) {
    if (newAxisType == checkAxis.type && thisAxisType != newAxisType) {
      TimetableAxis thisAxis = _getAxisOfType(thisAxisType);

      TimetableAxisType tmpXType = this._x.type;
      TimetableAxisType tmpYType = this._y.type;
      TimetableAxisType tmpZType = this._z.type;

      bool switchedThis = false;
      bool switchedNew = false;

      if (thisAxis.type == tmpXType) {
        this._x = checkAxis;
        switchedNew = true;
      } else if (thisAxis.type == tmpYType) {
        this._y = checkAxis;
        switchedNew = true;
      } else if (thisAxis.type == tmpZType) {
        this._z = checkAxis;
        switchedNew = true;
      }

      if (checkAxis.type == tmpXType) {
        this._x = thisAxis;
        switchedThis = true;
      } else if (checkAxis.type == tmpYType) {
        this._y = thisAxis;
        switchedThis = true;
      } else if (checkAxis.type == tmpZType) {
        this._z = thisAxis;
        switchedThis = true;
      }

      return switchedNew && switchedThis;
    } else {
      return false;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
/// TimetableSlot related classes
////////////////////////////////////////////////////////////////////////////////

class TimetableCoord {
  Weekday day;
  Time time;
  String custom;

  TimetableCoord({this.day, this.time, this.custom});

  TimetableCoord.copy(TimetableCoord coord)
      : day = coord.day,
        time = coord.time,
        custom = coord.custom;

  @override
  bool operator ==(coord) {
    return this.day == null ||
            this.time == null ||
            this.time.startTime == null ||
            this.time.endTime == null ||
            this.custom == null ||
            coord == null ||
            coord.day == null ||
            coord.time == null ||
            coord.time.startTime == null ||
            coord.time.endTime == null ||
            coord.custom == null
        ? false
        : this.day == coord.day &&
                this.time.startTime == coord.time.startTime &&
                this.time.endTime == coord.time.endTime &&
                this.custom == coord.custom
            ? true
            : false;
  }

  @override
  get hashCode => hash3(day, time, custom);
}

class TimetableSlotData {
  TimetableCoord _coord;
  String _subject;
  String _memberDisplay;

  TimetableSlotData({
    TimetableCoord coord,
    String subject,
    String memberDisplay,
  })  : _coord = coord,
        _subject = subject,
        _memberDisplay = memberDisplay;

  TimetableSlotData.copy(TimetableSlotData slotData)
      : _coord = slotData.coord,
        _subject = slotData.subject,
        _memberDisplay = slotData.memberDisplay;

  TimetableCoord get coord => this._coord;
  String get subject => this._subject;
  String get memberDisplay => this._memberDisplay;

  set coord(TimetableCoord val) => this._coord = val;
  set subject(String val) => this._subject = val;
  set memberDisplay(String val) => this._memberDisplay = val;

  bool hasSameCoordAs(TimetableCoord coord) {
    return coord == null ? false : this._coord == coord;
  }

  @override
  String toString() {
    String slotDataStr = '';
    slotDataStr += '<';
    slotDataStr += getWeekdayShortStr(coord.day);
    slotDataStr += ' : ';
    slotDataStr += DateFormat('hh:mm').format(coord.time.startTime);
    slotDataStr += '-';
    slotDataStr += DateFormat('hh:mm').format(coord.time.endTime);
    slotDataStr += ' : ';
    slotDataStr += coord.custom;
    slotDataStr += ' | ';
    slotDataStr += memberDisplay;
    slotDataStr += '>';
    return slotDataStr;
  }
}

class TimetableSlotDataList extends ChangeNotifier {
  List<TimetableSlotData> _value;

  TimetableSlotDataList({value}) : _value = value ?? [];

  TimetableSlotDataList.from(TimetableSlotDataList slotDataList)
      : _value = slotDataList._value ?? [];

  List<TimetableSlotData> get value => List.unmodifiable(this._value);

  @override
  String toString() {
    String string = '';
    _value.forEach((slotData) {
      string += slotData.toString() + '\n';
    });
    return string;
  }

  bool push(TimetableSlotData newSlotData) {
    if (newSlotData != null) {
      TimetableSlotData toRemove;

      for (TimetableSlotData slotData in this._value) {
        if (slotData.hasSameCoordAs(newSlotData.coord)) {
          toRemove = slotData;
          break;
        }
      }

      if (toRemove != null) {
        this._value.remove(toRemove);
      }

      this._value.add(newSlotData);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  bool pop(TimetableSlotData newSlotData) {
    TimetableSlotData toRemove;

    for (TimetableSlotData slotData in this._value) {
      if (slotData.hasSameCoordAs(newSlotData.coord)) {
        toRemove = slotData;
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

  /// convert slotDataList
  if (editTtb.slotDataList != null) {
    List<Map<String, dynamic>> slotDataList = [];

    editTtb.slotDataList.value.forEach((slotData) {
      if (editTtb.axisDay.contains(slotData.coord.day) &&
          editTtb.axisTime.contains(slotData.coord.time) &&
          editTtb.axisCustom.contains(slotData.coord.custom)) {
        /// convert coords
        Map<String, dynamic> coord = {
          'day': slotData.coord.day.index,
          'time': {
            'startTime': Timestamp.fromDate(slotData.coord.time.startTime),
            'endTime': Timestamp.fromDate(slotData.coord.time.endTime),
          },
          'custom': slotData.coord.custom,
        };

        /// convert subject
        String subject = slotData.subject;

        /// convert member
        String member = slotData.memberDisplay;

        /// add to list
        slotDataList.add({
          'coord': coord,
          'subject': subject,
          'member': member,
        });
      }
    });

    firestoreMap['slotDataList'] = slotDataList;
  }

  /// return final map in firestore format
  return firestoreMap;
}
