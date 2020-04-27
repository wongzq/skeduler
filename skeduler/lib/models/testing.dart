import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/time.dart';

enum TimetableAxisType { day, time, custom }

class TimetableAxis {
  TimetableAxisType _type;
  List<dynamic> _list;
  List<String> _listStr;

  TimetableAxis({
    @required TimetableAxisType type,
    List<dynamic> list,
    List<String> listStr,
  })  : _type = type,
        _list = list ?? [],
        _listStr = listStr ?? [];

  TimetableAxisType get type => this._type;
  List<dynamic> get list => () {
        switch (this._type) {
          case TimetableAxisType.day:
            return this._list as List<Weekday>;
            break;
          case TimetableAxisType.time:
            return this._list as List<Time>;
            break;
          case TimetableAxisType.custom:
            return this._list as List<String>;
            break;
          default:
            return null;
            break;
        }
      }();
  List<String> get listStr => this._listStr;

  set type(TimetableAxisType type) => this._type = type;
}

class TimetableAxes extends ChangeNotifier {
  /// properties
  TimetableAxis _x;
  TimetableAxis _y;
  TimetableAxis _z;

  /// constructors
  TimetableAxes({
    TimetableAxis x,
    TimetableAxis y,
    TimetableAxis z,
  }) {
    if (x == null) TimetableAxis(type: TimetableAxisType.day);
    if (y == null) TimetableAxis(type: TimetableAxisType.time);
    if (z == null) TimetableAxis(type: TimetableAxisType.custom);

    if (!updateAxes(x.type, y.type, z.type)) {
      this._x.type = TimetableAxisType.day;
      this._y.type = TimetableAxisType.time;
      this._z.type = TimetableAxisType.custom;
    }
    notifyListeners();
  }

  /// getter methods
  TimetableAxis get x => this._x;
  TimetableAxis get y => this._y;
  TimetableAxis get z => this._z;
  TimetableAxisType get xType => this._x.type;
  TimetableAxisType get yType => this._y.type;
  TimetableAxisType get zType => this._z.type;

  /// setter methods
  set xType(TimetableAxisType newX) {
    if (newX != this._x.type) {
      if (newX == this._y.type) {
        TimetableAxis tmpY = TimetableAxis(
          type: this._y.type,
          list: this._y._list,
          listStr: this._y._listStr,
        );

        this._y = TimetableAxis(
          type: this._x.type,
          list: this._x.list,
          listStr: this._x.listStr,
        );

        this._x = tmpY;
        notifyListeners();
      } else if (newX == this._z._type) {
        TimetableAxis tmpZ = TimetableAxis(
          type: this._z.type,
          list: this._z.list,
          listStr: this._z.listStr,
        );

        this._z = TimetableAxis(
          type: this._x.type,
          list: this._x.list,
          listStr: this._x.listStr,
        );

        this._x = tmpZ;
        notifyListeners();
      }
    }
  }

  set yType(TimetableAxisType newY) {
    if (newY != this._y._type) {
      if (newY == this._x._type) {
        TimetableAxis tmpX = TimetableAxis(
          type: this._x._type,
          list: this._x._list,
          listStr: this._x._listStr,
        );

        this._x = TimetableAxis(
          type: this._y._type,
          list: this._y._list,
          listStr: this._y._listStr,
        );

        this._y = tmpX;
        notifyListeners();
      } else if (newY == this._z._type) {
        TimetableAxis tmpZ = TimetableAxis(
          type: this._z._type,
          list: this._z._list,
          listStr: this._z._listStr,
        );

        this._z = TimetableAxis(
          type: this._y._type,
          list: this._y._list,
          listStr: this._y._listStr,
        );

        this._y = tmpZ;
        notifyListeners();
      }
    }
  }

  set zType(TimetableAxisType newZ) {
    if (newZ != this._z._type) {
      if (newZ == this._x._type) {
        TimetableAxis tmpX = TimetableAxis(
          type: this._x._type,
          list: this._x._list,
          listStr: this._x._listStr,
        );

        this._x = TimetableAxis(
          type: this._z._type,
          list: this._z._list,
          listStr: this._z._listStr,
        );

        this._z = tmpX;
        notifyListeners();
      } else if (newZ == this._y._type) {
        TimetableAxis tmpY = TimetableAxis(
          type: this._y._type,
          list: this._y._list,
          listStr: this._y._listStr,
        );

        this._z = TimetableAxis(
          type: this._z._type,
          list: this._z._list,
          listStr: this._z._listStr,
        );

        this._z = tmpY;
        notifyListeners();
      }
    }
  }

  /// auxiliary methods
  bool updateAxes(
    TimetableAxisType xType,
    TimetableAxisType yType,
    TimetableAxisType zType,
  ) {
    List<TimetableAxisType> axisTypes = [xType, yType, zType];

    if (axisTypes.contains(TimetableAxisType.day) &&
        axisTypes.contains(TimetableAxisType.time) &&
        axisTypes.contains(TimetableAxisType.custom)) {
      this._x.type = xType;
      this._y.type = yType;
      this._z.type = zType;
      return true;
    } else {
      return false;
    }
  }
}
