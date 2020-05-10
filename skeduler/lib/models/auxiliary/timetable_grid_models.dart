// abstract class [TimetableDragData]
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:quiver/core.dart';
import 'package:skeduler/models/group_data/time.dart';

// --------------------------------------------------------------------------------
// ScrollController classes for Provider
// --------------------------------------------------------------------------------
class TimetableScroll extends ChangeNotifier {
  LinkedScrollControllerGroup hori;
  LinkedScrollControllerGroup vert;
  List<ScrollController> _horiScroll;
  List<ScrollController> _vertScroll;

  bool changed;

  TimetableScroll({
    @required int horiLength,
    @required int vertLength,
  }) : changed = false {
    hori = LinkedScrollControllerGroup();
    vert = LinkedScrollControllerGroup();
    newTimetableScroll(
      horiLength: horiLength,
      vertLength: vertLength,
    );
  }

  void newTimetableScroll({
    @required int horiLength,
    @required int vertLength,
  }) {
    horiLength = horiLength == null || horiLength < 0 ? 0 : horiLength;
    horiLength = vertLength == null || vertLength < 0 ? 0 : vertLength;

    _horiScroll = [];
    for (int i = 0; i < horiLength + 1; i++) {
      this._horiScroll.add(this.hori.addAndGet());
    }

    _vertScroll = [];
    for (int i = 0; i < vertLength + 1; i++) {
      this._vertScroll.add(this.vert.addAndGet());
    }

    notifyListeners();
  }

  List<ScrollController> get horiScroll => List.unmodifiable(this._horiScroll);
  List<ScrollController> get vertScroll => List.unmodifiable(this._vertScroll);
}

// --------------------------------------------------------------------------------
// Timetable Drag Data related classes
// --------------------------------------------------------------------------------
abstract class TimetableDragData {
  String _display;

  String get display => this._display;
  bool get isEmpty => this._display == null || this._display.isEmpty;
  bool get isNotEmpty => this._display != null && this._display.isNotEmpty;

  bool get hasSubject;
  bool get hasMember;
  bool get hasSubjectOnly;
  bool get hasMemberOnly;
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

  bool get hasSubject => this.isNotEmpty;
  bool get hasMember => false;
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

  bool get hasSubject => false;
  bool get hasMember => this.isNotEmpty;
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

  bool get hasSubject => this.subject.isNotEmpty;
  bool get hasMember => this.member.isNotEmpty;
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
      ? this._subject.display + '\n' + this._member.display
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
  bool _editing;
  bool _viewMe;
  bool _binVisible;
  bool _dragSubject;
  bool _dragMember;
  bool _isDragging;
  TimetableDragData _isDraggingData;

  TimetableEditMode({bool editMode})
      : this._editing = editMode ?? false,
        this._viewMe = false,
        this._dragSubject = editMode,
        this._dragMember = editMode,
        this._isDragging = false,
        this._binVisible = false;

  bool get editing => this._editing;
  bool get viewMe => this._viewMe;
  bool get binVisible => this._binVisible;
  bool get dragSubject => this._editing ? this._dragSubject : false;
  bool get dragMember => this._editing ? this._dragMember : false;
  bool get dragSubjectOnly =>
      this._editing ? this._dragSubject && !this._dragMember : false;
  bool get dragMemberOnly =>
      this._editing ? !this._dragSubject && this._dragMember : false;
  bool get dragSubjectAndMember =>
      this._editing ? this._dragSubject && this._dragMember : false;
  bool get isDragging => this._editing ? this._isDragging : false;
  TimetableDragData get isDraggingData =>
      this._editing ? this._isDraggingData : null;

  set editing(bool value) {
    this._editing = value;
    notifyListeners();
  }

  set viewMe(bool value) {
    this._viewMe = value;
    notifyListeners();
  }

  set dragSubject(bool value) {
    this._dragSubject = this._editing ? value : this._dragSubject;
    notifyListeners();
  }

  set dragMember(bool value) {
    this._dragMember = this._editing ? value : this._dragMember;
    notifyListeners();
  }

  set isDragging(bool value) {
    this._isDragging = this._editing ? value : this._isDragging;
    notifyListeners();
  }

  set isDraggingData(TimetableDragData value) {
    this._isDraggingData = this._editing ? value : this._isDragging;
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

enum GridAxis { x, y, z }

enum DataAxis { day, time, custom }

String getAxisTypeStr(DataAxis axisType) {
  switch (axisType) {
    case DataAxis.day:
      return 'Day';
      break;
    case DataAxis.time:
      return 'Time';
      break;
    case DataAxis.custom:
      return 'Custom';
      break;
    default:
      return '';
      break;
  }
}

class TimetableAxis {
  GridAxis _gridAxis;
  DataAxis _dataAxis;
  List<dynamic> _list;
  List<String> _listStr;

  TimetableAxis({
    @required GridAxis gridAxis,
    @required DataAxis dataAxis,
    List<dynamic> list,
    List<String> listStr,
  })  : this._gridAxis = gridAxis,
        this._dataAxis = dataAxis,
        this._list = list ?? [],
        this._listStr = listStr ?? [];

  TimetableAxis.copy(TimetableAxis ttbAxis)
      : this._gridAxis = ttbAxis.gridAxis,
        this._dataAxis = ttbAxis.dataAxis,
        this._list = ttbAxis.list == null ? [] : List.from(ttbAxis.list),
        this._listStr =
            ttbAxis.listStr == null ? [] : List.from(ttbAxis.listStr);

  GridAxis get gridAxis => this._gridAxis;
  DataAxis get dataAxis => this._dataAxis;
  List get list => () {
        switch (this._dataAxis) {
          case DataAxis.day:
            return this._list;
            break;
          case DataAxis.time:
            return this._list;
            break;
          case DataAxis.custom:
            return this._list;
            break;
          default:
            return null;
            break;
        }
      }();
  List<String> get listStr => this._listStr;

  set gridAxis(GridAxis gridAxis) => this._gridAxis = gridAxis;
  set dataAxis(DataAxis dataAxis) => this._dataAxis = dataAxis;
}

class TimetableAxes extends ChangeNotifier {
  TimetableAxis _day;
  TimetableAxis _time;
  TimetableAxis _custom;

  bool _isEmpty;

  // constructors
  TimetableAxes.empty() : this._isEmpty = true;

  TimetableAxes({
    TimetableAxis day,
    TimetableAxis time,
    TimetableAxis custom,
  }) {
    if (day == null || time == null || custom == null) {
      this._day = TimetableAxis(
        gridAxis: GridAxis.x,
        dataAxis: DataAxis.day,
      );
      this._time = TimetableAxis(
        gridAxis: GridAxis.y,
        dataAxis: DataAxis.time,
      );
      this._custom = TimetableAxis(
        gridAxis: GridAxis.z,
        dataAxis: DataAxis.custom,
      );
    } else if (!updateAxes(x: day, y: time, z: custom)) {
      this._day = TimetableAxis(
        gridAxis: GridAxis.x,
        dataAxis: DataAxis.day,
      );
      this._time = TimetableAxis(
        gridAxis: GridAxis.y,
        dataAxis: DataAxis.time,
      );
      this._custom = TimetableAxis(
        gridAxis: GridAxis.z,
        dataAxis: DataAxis.custom,
      );
    }

    this._isEmpty = false;

    notifyListeners();
  }

  // getter methods
  bool get isEmpty => this._isEmpty;

  DataAxis get xDataAxis => _axisFromGridAxis(GridAxis.x).dataAxis;
  DataAxis get yDataAxis => _axisFromGridAxis(GridAxis.y).dataAxis;
  DataAxis get zDataAxis => _axisFromGridAxis(GridAxis.z).dataAxis;
  List<dynamic> get xList => _axisFromGridAxis(GridAxis.x).list;
  List<dynamic> get yList => _axisFromGridAxis(GridAxis.y).list;
  List<dynamic> get zList => _axisFromGridAxis(GridAxis.z).list;
  List<String> get xListStr => _axisFromGridAxis(GridAxis.x).listStr;
  List<String> get yListStr => _axisFromGridAxis(GridAxis.y).listStr;
  List<String> get zListStr => _axisFromGridAxis(GridAxis.z).listStr;

  GridAxis get dayGridAxis => _axisFromDataAxis(DataAxis.day).gridAxis;
  GridAxis get timeGridAxis => _axisFromDataAxis(DataAxis.time).gridAxis;
  GridAxis get customGridAxis => _axisFromDataAxis(DataAxis.custom).gridAxis;
  List<dynamic> get dayList => _axisFromDataAxis(DataAxis.day).list;
  List<dynamic> get timeList => _axisFromDataAxis(DataAxis.time).list;
  List<dynamic> get customList => _axisFromDataAxis(DataAxis.custom).list;
  List<String> get dayListStr => _axisFromDataAxis(DataAxis.day).listStr;
  List<String> get timeListStr => _axisFromDataAxis(DataAxis.time).listStr;
  List<String> get customListStr => _axisFromDataAxis(DataAxis.custom).listStr;

  // setter methods
  set dayGridAxis(GridAxis gridAxis) {
    _swapGridAxis(DataAxis.day, gridAxis);
    notifyListeners();
  }

  set timeGridAxis(GridAxis gridAxis) {
    _swapGridAxis(DataAxis.time, gridAxis);
    notifyListeners();
  }

  set customGridAxis(GridAxis gridAxis) {
    _swapGridAxis(DataAxis.custom, gridAxis);
    notifyListeners();
  }

  set dayKeepGridAxis(TimetableAxis ttbAxis) {
    this._day = TimetableAxis(
      gridAxis: this._day.gridAxis,
      dataAxis: ttbAxis.dataAxis,
      list: ttbAxis.list,
      listStr: ttbAxis.listStr,
    );
    notifyListeners();
  }

  set timeKeepGridAxis(TimetableAxis ttbAxis) {
    this._time = TimetableAxis(
      gridAxis: this._time.gridAxis,
      dataAxis: ttbAxis.dataAxis,
      list: ttbAxis.list,
      listStr: ttbAxis.listStr,
    );
    notifyListeners();
  }

  set customKeepGridAxis(TimetableAxis ttbAxis) {
    this._custom = TimetableAxis(
      gridAxis: this._custom.gridAxis,
      dataAxis: ttbAxis.dataAxis,
      list: ttbAxis.list,
      listStr: ttbAxis.listStr,
    );
    notifyListeners();
  }

  void _swapGridAxis(DataAxis thisDataAxis, GridAxis newGridAxis) {
    GridAxis thisGridAxis;

    // if this is day
    if (_day.dataAxis == thisDataAxis) {
      thisGridAxis = _day.gridAxis;
      _day.gridAxis = newGridAxis;
      if (_time.gridAxis == newGridAxis) {
        _time.gridAxis = thisGridAxis;
      } else if (_custom.gridAxis == newGridAxis) {
        _custom.gridAxis = thisGridAxis;
      }
    }
    // if this is time
    else if (_time.dataAxis == thisDataAxis) {
      thisGridAxis = _time.gridAxis;
      _time.gridAxis = newGridAxis;
      if (_day.gridAxis == newGridAxis) {
        _day.gridAxis = thisGridAxis;
      } else if (_custom.gridAxis == newGridAxis) {
        _custom.gridAxis = thisGridAxis;
      }
    }
    // if this is custom
    else if (_custom.dataAxis == thisDataAxis) {
      thisGridAxis = _custom.gridAxis;
      _custom.gridAxis = newGridAxis;
      if (_day.gridAxis == newGridAxis) {
        _day.gridAxis = thisGridAxis;
      } else if (_time.gridAxis == newGridAxis) {
        _time.gridAxis = thisGridAxis;
      }
    }
  }

  // auxiliary methods
  @override
  String toString() {
    return _day.gridAxis.toString() +
        ' ' +
        _day.dataAxis.toString() +
        '\n' +
        _time.gridAxis.toString() +
        ' ' +
        _time.dataAxis.toString() +
        '\n' +
        _custom.gridAxis.toString() +
        ' ' +
        _custom.dataAxis.toString();
  }

  bool updateAxes({
    TimetableAxis x,
    TimetableAxis y,
    TimetableAxis z,
  }) {
    x = x ?? this._day;
    y = y ?? this._time;
    z = z ?? this._custom;

    List<DataAxis> axesTypes = [
      x.dataAxis,
      y.dataAxis,
      z.dataAxis,
    ];

    if (axesTypes.contains(DataAxis.day) &&
        axesTypes.contains(DataAxis.time) &&
        axesTypes.contains(DataAxis.custom)) {
      this._day = x;
      this._time = y;
      this._custom = z;

      _isEmpty = false;

      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void clearAxes() {
    this._day = null;
    this._time = null;
    this._custom = null;

    _isEmpty = true;
    notifyListeners();
  }

  TimetableAxis _axisFromDataAxis(DataAxis dataAxis) {
    return this._day.dataAxis == dataAxis
        ? this._day
        : this._time.dataAxis == dataAxis
            ? this._time
            : this._custom.dataAxis == dataAxis ? this._custom : null;
  }

  TimetableAxis _axisFromGridAxis(GridAxis gridAxis) {
    return this._day.gridAxis == gridAxis
        ? this._day
        : this._time.gridAxis == gridAxis
            ? this._time
            : this._custom.gridAxis == gridAxis ? this._custom : null;
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
