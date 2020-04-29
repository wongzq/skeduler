import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_headers.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_slots.dart';

class TimetableGrid extends StatefulWidget {
  // constructors
  TimetableGrid({
    Key key,
  }) : super(key: key);

  @override
  _TimetableGridState createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  @override
  Widget build(BuildContext context) {
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    EditModeBool _editMode = Provider.of<EditModeBool>(context);
    TimetableAxes _axes = Provider.of<TimetableAxes>(context);

    TimetableAxis _day = TimetableAxis(
      type: TimetableAxisType.day,
      list: _editMode.value ? ttbStatus.perm.axisDay : ttbStatus.curr.axisDay,
      listStr: _editMode.value
          ? ttbStatus.perm.axisDayShortStr
          : ttbStatus.curr.axisDayShortStr,
    );

    TimetableAxis _time = TimetableAxis(
      type: TimetableAxisType.time,
      list: _editMode.value ? ttbStatus.perm.axisTime : ttbStatus.curr.axisTime,
      listStr: _editMode.value
          ? ttbStatus.perm.axisTimeStr
          : ttbStatus.curr.axisTimeStr,
    );

    TimetableAxis _custom = TimetableAxis(
      type: TimetableAxisType.custom,
      list: _editMode.value
          ? ttbStatus.perm.axisCustom
          : ttbStatus.curr.axisCustom,
      listStr: _editMode.value
          ? ttbStatus.perm.axisCustom
          : ttbStatus.curr.axisCustom,
    );

    TimetableAxis _getAxisOfType(TimetableAxisType axisType) {
      switch (axisType) {
        case TimetableAxisType.day:
          return _day;
          break;
        case TimetableAxisType.time:
          return _time;
          break;
        case TimetableAxisType.custom:
          return _custom;
          break;
        default:
          return null;
          break;
      }
    }

    if (_axes.isEmpty) {
      _axes.updateAxes(x: _day, y: _time, z: _custom);
    } else {
      _axes.updateAxes(
        x: _getAxisOfType(_axes.xType),
        y: _getAxisOfType(_axes.yType),
        z: _getAxisOfType(_axes.zType),
      );
    }

    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.max,
      children: [
        TimetableHeaderX(axisX: _axes.xListStr),
        Expanded(
          flex: (_axes.yListStr.length ?? 0) * (_axes.zListStr.length ?? 0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TimetableHeaderYZ(
                axisY: _axes.yListStr,
                axisZ: _axes.zListStr,
              ),
              TimetableSlots(
                xType: _axes.xType,
                yType: _axes.yType,
                zType: _axes.zType,
                xList: _axes.xList,
                yList: _axes.yList,
                zList: _axes.zList,
                xListStr: _axes.xListStr,
                yListStr: _axes.yListStr,
                zListStr: _axes.zListStr,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
