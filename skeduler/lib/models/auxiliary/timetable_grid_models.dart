// abstract class [TimetableDragData]
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:quiver/core.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/models/group_data/timetable.dart';

// --------------------------------------------------------------------------------
// TimetableStatus class for Provider
// --------------------------------------------------------------------------------

class TimetableStatus extends ChangeNotifier {
  // properties
  // current
  Timetable _curr;
  TimetableAxes _currAxes;
  TimetableScroll _currScroll;
  bool _currAxesIsCustom;

  // editing
  EditTimetable _edit;
  TimetableAxes _editAxes;
  TimetableScroll _editScroll;

  // temporary
  EditTimetable _temp;

  // getter methods
  Timetable get curr => this._curr;
  TimetableAxes get currAxes => this._currAxes;
  TimetableScroll get currScroll => this._currScroll;
  bool get currAxesIsCustom => this._currAxesIsCustom;

  EditTimetable get edit => this._edit;
  TimetableAxes get editAxes => this._editAxes;
  TimetableScroll get editScroll => this._editScroll;

  EditTimetable get temp => this._temp;

  set currAxesIsCustom(bool isCustom) {
    this._currAxesIsCustom = isCustom;
    notifyListeners();
  }

  // setter methods
  set curr(Timetable ttb) {
    this._curr = ttb;

    // reset currAxes
    if (ttb == null) {
      this._currAxes = null;
      this._currScroll = null;
      this._currAxesIsCustom = false;
    }
    // new currAxes
    else if (this._currAxes == null) {
      this._currAxesIsCustom = false;
      this._currAxes = _newAxes(
        this._curr == null ? EditTimetable() : EditTimetable.fromTimetable(ttb),
      );
      this._currScroll = TimetableScroll(horiLength: 100, vertLength: 100);
    }
    // update currAxes keep grid axis
    else {
      if (this._currAxesIsCustom == false) {
        this._currAxesIsCustom = false;
        this._currAxes = _newAxes(
          this._curr == null
              ? EditTimetable()
              : EditTimetable.fromTimetable(ttb),
        );
        this._currScroll = TimetableScroll(horiLength: 100, vertLength: 100);
      } else {
        this._currAxes = _updateAxesKeepGridAxis(
          this._curr == null
              ? EditTimetable()
              : EditTimetable.fromTimetable(ttb),
          this._currAxes,
        );
      }
    }
  }

  set edit(EditTimetable editTtb) {
    this._edit = editTtb;

    // reset editAxes
    if (editTtb == null) {
      this._editAxes = null;
      this._editScroll = null;
    }
    // new editAxes
    else if (this._editAxes == null) {
      this._editAxes = _newAxes(editTtb);
      this._editScroll = TimetableScroll(horiLength: 100, vertLength: 100);
    }
    // update editAxes keep grid axes
    else {
      this._editAxes = _updateAxesKeepGridAxis(editTtb, this._editAxes);
    }
  }

  set temp(EditTimetable editTtb) {
    this._temp = editTtb;
  }

  set currDayGridAxis(GridAxis gridAxis) {
    this._currAxes.dayGridAxis = gridAxis;
    notifyListeners();
  }

  set currTimeGridAxis(GridAxis gridAxis) {
    this._currAxes.timeGridAxis = gridAxis;
    notifyListeners();
  }

  set currCustomGridAxis(GridAxis gridAxis) {
    this._currAxes.customGridAxis = gridAxis;
    notifyListeners();
  }

  set editDayGridAxis(GridAxis gridAxis) {
    this._editAxes.dayGridAxis = gridAxis;
    this._edit.gridAxisOfDay = this._editAxes.dayGridAxis;
    this._edit.gridAxisOfTime = this._editAxes.timeGridAxis;
    this._edit.gridAxisOfCustom = this._editAxes.customGridAxis;
    notifyListeners();
  }

  set editTimeGridAxis(GridAxis gridAxis) {
    this._editAxes.timeGridAxis = gridAxis;
    this._edit.gridAxisOfDay = this._editAxes.dayGridAxis;
    this._edit.gridAxisOfTime = this._editAxes.timeGridAxis;
    this._edit.gridAxisOfCustom = this._editAxes.customGridAxis;
    notifyListeners();
  }

  set editCustomGridAxis(GridAxis gridAxis) {
    this._editAxes.customGridAxis = gridAxis;
    this._edit.gridAxisOfDay = this._editAxes.dayGridAxis;
    this._edit.gridAxisOfTime = this._editAxes.timeGridAxis;
    this._edit.gridAxisOfCustom = this._editAxes.customGridAxis;
    notifyListeners();
  }

  // auxiliary methods
  TimetableAxes _newAxes(EditTimetable editTtb) {
    return TimetableAxes(
      day: TimetableAxis(
        gridAxis: editTtb.gridAxisOfDay,
        dataAxis: DataAxis.day,
        list: editTtb.axisDay,
        listStr: editTtb.axisDayShortStr,
      ),
      time: TimetableAxis(
        gridAxis: editTtb.gridAxisOfTime,
        dataAxis: DataAxis.time,
        list: editTtb.axisTime,
        listStr: editTtb.axisTimeStr,
      ),
      custom: TimetableAxis(
        gridAxis: editTtb.gridAxisOfCustom,
        dataAxis: DataAxis.custom,
        list: editTtb.axisCustom,
        listStr: editTtb.axisCustom,
      ),
    );
  }

  TimetableAxes _updateAxesKeepGridAxis(
      EditTimetable editTtb, TimetableAxes keepGridAxis) {
    return TimetableAxes(
      day: TimetableAxis(
        gridAxis: keepGridAxis.dayGridAxis,
        dataAxis: DataAxis.day,
        list: editTtb.axisDay,
        listStr: editTtb.axisDayShortStr,
      ),
      time: TimetableAxis(
        gridAxis: keepGridAxis.timeGridAxis,
        dataAxis: DataAxis.time,
        list: editTtb.axisTime,
        listStr: editTtb.axisTimeStr,
      ),
      custom: TimetableAxis(
        gridAxis: keepGridAxis.customGridAxis,
        dataAxis: DataAxis.custom,
        list: editTtb.axisCustom,
        listStr: editTtb.axisCustom,
      ),
    );
  }

  void update() {
    this.curr = this._curr;
    this.edit = this._edit;
    this.temp = this._temp;
    notifyListeners();
  }

  void reset() {
    this.curr = null;
    this.edit = null;
    this.temp = null;
    this._currAxesIsCustom = false;
    notifyListeners();
  }
}

// --------------------------------------------------------------------------------
// TimetableScroll class for Provider
// --------------------------------------------------------------------------------

class TimetableScroll extends ChangeNotifier {
  // properties
  LinkedScrollControllerGroup hori;
  LinkedScrollControllerGroup vert;
  List<ScrollController> _horiScroll;
  List<ScrollController> _vertScroll;

  bool changed;

  // constructor
  TimetableScroll({
    @required int horiLength,
    @required int vertLength,
  }) : changed = false {
    hori = LinkedScrollControllerGroup();
    vert = LinkedScrollControllerGroup();
    _newTimetableScroll(
      horiLength: horiLength,
      vertLength: vertLength,
    );
  }

  // methods
  void _newTimetableScroll({
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
  // properties
  String _display;

  // getter methods
  String get display => this._display;
  bool get isEmpty => this._display == null || this._display.isEmpty;
  bool get isNotEmpty => this._display != null && this._display.isNotEmpty;

  // abstract getter methods
  bool get hasSubject;
  bool get hasMember;
  bool get hasSubjectOnly;
  bool get hasMemberOnly;
  bool get hasSubjectAndMember;
}

// [TimetableDragDataSubject] class
class TimetableDragSubject extends TimetableDragData {
  // constructors
  TimetableDragSubject({String display}) {
    super._display = display;
  }

  // getter methods
  @override
  String get display => super._display;
  bool get isEmpty => super.isEmpty;
  bool get isNotEmpty => super.isNotEmpty;

  bool get hasSubject => this.isNotEmpty;
  bool get hasMember => false;
  bool get hasSubjectOnly => this.isNotEmpty;
  bool get hasMemberOnly => false;
  bool get hasSubjectAndMember => false;

  // setter methods
  set display(String value) => super._display = value;
}

// [TimetableDragDataMember] class
class TimetableDragMember extends TimetableDragData {
  // constructors
  TimetableDragMember({String display}) {
    super._display = display;
  }

  // getter methods
  String get display => super._display;
  bool get isEmpty => super.isEmpty;
  bool get isNotEmpty => super.isNotEmpty;

  bool get hasSubject => false;
  bool get hasMember => this.isNotEmpty;
  bool get hasSubjectOnly => false;
  bool get hasMemberOnly => this.isNotEmpty;
  bool get hasSubjectAndMember => false;

  // setter methods
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
// TimetableEditMode class for Provider
// --------------------------------------------------------------------------------

class TimetableEditMode extends ChangeNotifier {
  // properties
  bool _editing;
  bool _viewMe;
  bool _binVisible;
  bool _dragSubject;
  bool _dragMember;
  bool _isDragging;
  TimetableDragData _isDraggingData;

  // constructors
  TimetableEditMode({bool editMode})
      : this._editing = editMode ?? false,
        this._viewMe = false,
        this._dragSubject = editMode,
        this._dragMember = editMode,
        this._isDragging = false,
        this._binVisible = false;

  // getter methods
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

  // setter methods
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
  // properties
  GridAxis _gridAxis;
  DataAxis _dataAxis;
  List<dynamic> _list;
  List<String> _listStr;

  // constructors
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

  // getter methods
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

  // setter methods
  set gridAxis(GridAxis gridAxis) => this._gridAxis = gridAxis;
  set dataAxis(DataAxis dataAxis) => this._dataAxis = dataAxis;
}

class TimetableAxes extends ChangeNotifier {
  // properties
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
    } else if (!_updateAxes(x: day, y: time, z: custom)) {
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

  // auxiliary methods
  void _swapGridAxis(DataAxis thisDataAxis, GridAxis newGridAxis) {
    GridAxis thisGridAxis;

    // if this is day
    if (this._day.dataAxis == thisDataAxis) {
      thisGridAxis = this._day.gridAxis;
      this._day.gridAxis = newGridAxis;
      if (this._time.gridAxis == newGridAxis) {
        this._time.gridAxis = thisGridAxis;
      } else if (this._custom.gridAxis == newGridAxis) {
        this._custom.gridAxis = thisGridAxis;
      }
    }

    // if this is time
    else if (this._time.dataAxis == thisDataAxis) {
      thisGridAxis = this._time.gridAxis;
      this._time.gridAxis = newGridAxis;
      if (this._day.gridAxis == newGridAxis) {
        this._day.gridAxis = thisGridAxis;
      } else if (this._custom.gridAxis == newGridAxis) {
        this._custom.gridAxis = thisGridAxis;
      }
    }

    // if this is custom
    else if (this._custom.dataAxis == thisDataAxis) {
      thisGridAxis = this._custom.gridAxis;
      this._custom.gridAxis = newGridAxis;
      if (this._day.gridAxis == newGridAxis) {
        this._day.gridAxis = thisGridAxis;
      } else if (this._time.gridAxis == newGridAxis) {
        this._time.gridAxis = thisGridAxis;
      }
    }
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

  bool _updateAxes({
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

      this._isEmpty = false;

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

    this._isEmpty = true;
    notifyListeners();
  }

  @override
  String toString() {
    return this._day.gridAxis.toString() +
        ' ' +
        this._day.dataAxis.toString() +
        ', ' +
        this._time.gridAxis.toString() +
        ' ' +
        this._time.dataAxis.toString() +
        ', ' +
        this._custom.gridAxis.toString() +
        ' ' +
        this._custom.dataAxis.toString();
    // return this._day.gridAxis.toString() +
    //     ' ' +
    //     this._day.dataAxis.toString() +
    //     '\n' +
    //     this._time.gridAxis.toString() +
    //     ' ' +
    //     this._time.dataAxis.toString() +
    //     '\n' +
    //     this._custom.gridAxis.toString() +
    //     ' ' +
    //     this._custom.dataAxis.toString();
  }
}

// --------------------------------------------------------------------------------
// TimetableCoord related classes
// --------------------------------------------------------------------------------

class TimetableCoord {
  // properties
  Weekday day;
  Time time;
  String custom;

  // constructors
  TimetableCoord({this.day, this.time, this.custom});

  TimetableCoord.copy(TimetableCoord coord)
      : this.day = coord.day,
        this.time = coord.time,
        this.custom = coord.custom;

  // methods
  @override
  bool operator ==(o) {
    return this.day == null ||
            this.time == null ||
            this.time.startTime == null ||
            this.time.endTime == null ||
            this.custom == null ||
            o == null ||
            o.day == null ||
            o.time == null ||
            o.time.startTime == null ||
            o.time.endTime == null ||
            o.custom == null
        ? false
        : this.day == o.day &&
                this.time.startTime == o.time.startTime &&
                this.time.endTime == o.time.endTime &&
                this.custom == o.custom
            ? true
            : false;
  }

  @override
  get hashCode => hash3(day, time, custom);
}

// --------------------------------------------------------------------------------
// TimetableGridData class
// --------------------------------------------------------------------------------

class TimetableGridData {
  // properties
  TimetableCoord _coord;
  TimetableDragSubjectMember _dragData;

  // constructors
  TimetableGridData({
    TimetableCoord coord,
    TimetableDragSubjectMember dragData,
  })  : this._coord = coord ?? TimetableCoord(),
        this._dragData = dragData ?? TimetableDragSubjectMember();

  TimetableGridData.copy(TimetableGridData gridData)
      : this._coord = gridData.coord,
        this._dragData = gridData._dragData;

  // getter methods
  TimetableCoord get coord => this._coord;
  TimetableDragSubjectMember get dragData => this._dragData;

  // setter methods
  set coord(TimetableCoord val) => this._coord = val;
  set dragData(TimetableDragSubjectMember val) => this._dragData = val;

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

// --------------------------------------------------------------------------------
// TimetableGridDataList class for Provider
// --------------------------------------------------------------------------------

class TimetableGridDataList extends ChangeNotifier {
  // properties
  List<TimetableGridData> _value;

  // constructors
  TimetableGridDataList({List<TimetableGridData> value})
      : this._value = value ?? [];

  TimetableGridDataList.from(TimetableGridDataList gridDataList)
      : this._value = gridDataList._value ?? [];

  // getter methods
  List<TimetableGridData> get value => List.unmodifiable(this._value);

  // methods
  bool push(TimetableGridData newGridData) {
    if (newGridData != null) {
      TimetableGridData toRemove;

      for (TimetableGridData gridData in this._value) {
        if (gridData.coord == newGridData.coord) {
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
      if (gridData.coord == newGridData.coord) {
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

  void popAll() {
    this._value = [];
  }

  @override
  String toString() {
    String string = '';
    this._value.forEach((gridData) {
      string += gridData.toString() + '\n';
    });
    return string;
  }
}
