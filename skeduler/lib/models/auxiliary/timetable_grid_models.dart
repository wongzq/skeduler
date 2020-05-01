// abstract class [TimetableDragData]
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/core.dart';
import 'package:skeduler/models/group_data/time.dart';

abstract class TimetableDragData {
  String _display;

  String get display => this._display;
  bool get isEmpty => this._display == null || this._display.isEmpty;
  bool get isNotEmpty => this._display != null && this._display.isNotEmpty;

  bool get hasSubjectOnly => true;
  bool get hasMemberOnly => true;
  bool get hasSubjectAndMember;
}

// [TimetableDragDataSubject] class
class TimetableDragSubject extends TimetableDragData {
  TimetableDragSubject({String display}) {
    super._display = display;
  }

  @override
  String get display => super._display;
  bool get isEmpty => super.isEmpty;
  bool get isNotEmpty => super.isNotEmpty;

  bool get hasSubjectOnly => this.isNotEmpty;
  bool get hasMemberOnly => false;
  bool get hasSubjectAndMember => false;

  set display(String value) => super._display = value;
}

// [TimetableDragDataMember] class
class TimetableDragMember extends TimetableDragData {
  TimetableDragMember({String display}) {
    super._display = display;
  }

  String get display => super._display;
  bool get isEmpty => super.isEmpty;
  bool get isNotEmpty => super.isNotEmpty;

  bool get hasSubjectOnly => false;
  bool get hasMemberOnly => this.isNotEmpty;
  bool get hasSubjectAndMember => false;

  set display(String value) => super._display = value;
}

// [TimetableDragDataSubjectMember] class
class TimetableDragSubjectMember extends TimetableDragData {
  // properties
  TimetableDragSubject _subject;
  TimetableDragMember _member;

  // constructors
  TimetableDragSubjectMember({
    TimetableDragSubject subject,
    TimetableDragMember member,
  })  : this._subject = subject ?? TimetableDragSubject(),
        this._member = member ?? TimetableDragMember() {
    super._display = _getDisplay();
  }

  // getter methods
  TimetableDragSubject get subject => this._subject;
  TimetableDragMember get member => this._member;
  String get display => _getDisplay();
  bool get isEmpty => this._subject.isEmpty && this._member.isEmpty;
  bool get isNotEmpty => this._subject.isNotEmpty || this._member.isNotEmpty;

  bool get hasSubjectOnly => this._subject.isNotEmpty && this._member.isEmpty;
  bool get hasMemberOnly => this._subject.isEmpty && this._member.isNotEmpty;
  bool get hasSubjectAndMember =>
      this._subject.isNotEmpty && this._member.isNotEmpty;

  // setter methods
  set subject(TimetableDragSubject subject) {
    this._subject = subject;
    super._display = _getDisplay();
  }

  set member(TimetableDragMember member) {
    this._member = member;
    super._display = _getDisplay();
  }

  // auxiliary methods
  String _getDisplay() => this._subject.isNotEmpty && this._member.isNotEmpty
      ? this._subject.display + ' : ' + this._member.display
      : this._subject.isNotEmpty && this._member.isEmpty
          ? this._subject.display
          : this._subject.isEmpty && this._member.isNotEmpty
              ? this._member.display
              : null;
}

// --------------------------------------------------------------------------------
// TimetableDisplayInfo class for Provider
// --------------------------------------------------------------------------------

class TimetableEditMode extends ChangeNotifier {
  bool _editMode;
  bool _dragSubject;
  bool _dragMember;
  bool _isDragging;
  TimetableDragData _isDraggingData;
  bool _binVisible;

  TimetableEditMode({bool editMode})
      : this._editMode = editMode ?? false,
        this._dragSubject = editMode,
        this._dragMember = editMode,
        this._isDragging = false,
        this._binVisible = false;

  bool get editMode => this._editMode;
  bool get dragSubject => this._editMode ? this._dragSubject : false;
  bool get dragMember => this._editMode ? this._dragMember : false;
  bool get dragSubjectOnly =>
      this._editMode ? this._dragSubject && !this._dragMember : false;
  bool get dragMemberOnly =>
      this._editMode ? !this._dragSubject && this._dragMember : false;
  bool get dragSubjectAndMember =>
      this._editMode ? this._dragSubject && this._dragMember : false;
  bool get isDragging => this._editMode ? this._isDragging : false;
  TimetableDragData get isDraggingData =>
      this._editMode ? this._isDraggingData : null;
  bool get binVisible => this._binVisible;

  set editMode(bool value) {
    this._editMode = value;
    notifyListeners();
  }

  set dragSubject(bool value) {
    this._dragSubject = this._editMode ? value : this._dragSubject;
    notifyListeners();
  }

  set dragMember(bool value) {
    this._dragMember = this._editMode ? value : this._dragMember;
    notifyListeners();
  }

  set isDragging(bool value) {
    this._isDragging = this._editMode ? value : this._isDragging;
    notifyListeners();
  }

  set isDraggingData(TimetableDragData value) {
    this._isDraggingData = this._editMode ? value : this._isDragging;
    notifyListeners();
  }

  set binVisible(bool value) {
    this._binVisible = value;
    notifyListeners();
  }
}

// --------------------------------------------------------------------------------
// TimetableAxis related classes
// --------------------------------------------------------------------------------

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
  // properties
  TimetableAxis _x;
  TimetableAxis _y;
  TimetableAxis _z;
  bool _empty;

  // constructors
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

  // getter methods
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

  // setter methods
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

  // auxiliary methods
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

// --------------------------------------------------------------------------------
// TimetableSlot related classes
// --------------------------------------------------------------------------------

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

class TimetableGridData {
  TimetableCoord _coord;
  TimetableDragSubjectMember _dragData;

  TimetableGridData({
    TimetableCoord coord,
    TimetableDragSubjectMember dragData,
  })  : _coord = coord ?? TimetableCoord(),
        _dragData = dragData ?? TimetableDragSubjectMember();

  TimetableGridData.copy(TimetableGridData gridData)
      : _coord = gridData.coord,
        _dragData = gridData._dragData;

  TimetableCoord get coord => this._coord;
  TimetableDragSubjectMember get dragData => this._dragData;

  set coord(TimetableCoord val) => this._coord = val;
  set dragData(TimetableDragSubjectMember val) => this._dragData = val;

  bool hasSameCoordAs(TimetableCoord coord) {
    return coord == null ? false : this._coord == coord;
  }

  @override
  String toString() {
    String gridDataStr = '';
    gridDataStr += '<';
    gridDataStr += getWeekdayShortStr(this._coord.day);
    gridDataStr += ' : ';
    gridDataStr += DateFormat('hh:mm').format(this._coord.time.startTime);
    gridDataStr += '-';
    gridDataStr += DateFormat('hh:mm').format(this._coord.time.endTime);
    gridDataStr += ' : ';
    gridDataStr += this._coord.custom;
    gridDataStr += ' | ';
    gridDataStr += this._dragData.display;
    gridDataStr += '>';
    return gridDataStr;
  }
}

class TimetableGridDataList extends ChangeNotifier {
  List<TimetableGridData> _value;

  TimetableGridDataList({value}) : _value = value ?? [];

  TimetableGridDataList.from(TimetableGridDataList gridDataList)
      : _value = gridDataList._value ?? [];

  List<TimetableGridData> get value => List.unmodifiable(this._value);

  @override
  String toString() {
    String string = '';
    _value.forEach((gridData) {
      string += gridData.toString() + '\n';
    });
    return string;
  }

  bool push(TimetableGridData newGridData) {
    if (newGridData != null) {
      TimetableGridData toRemove;

      for (TimetableGridData gridData in this._value) {
        if (gridData.hasSameCoordAs(newGridData.coord)) {
          toRemove = gridData;
          break;
        }
      }

      if (toRemove != null) {
        this._value.remove(toRemove);
      }

      this._value.add(newGridData);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  bool pop(TimetableGridData newGridData) {
    TimetableGridData toRemove;

    for (TimetableGridData gridData in this._value) {
      if (gridData.hasSameCoordAs(newGridData.coord)) {
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
