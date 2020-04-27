import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_headers.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_slots.dart';

class TimetableGrid extends StatefulWidget {
  /// constructors
  TimetableGrid({
    Key key,
  }) : super(key: key);

  @override
  _TimetableGridState createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  /// properties

  TimetableAxes _axes = TimetableAxes();

  TimetableSlotDataList _slotDataList = TimetableSlotDataList();

  /// methods
  @override
  Widget build(BuildContext context) {
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    EditModeBool editMode = Provider.of<EditModeBool>(context);

    TimetableAxis _x = TimetableAxis(
        type: TimetableAxisType.day,
        list: editMode.value ? ttbStatus.perm.axisDay : ttbStatus.curr.axisDay,
        listStr: editMode.value
            ? ttbStatus.perm.axisDayShortStr
            : ttbStatus.curr.axisDayShortStr);

    TimetableAxis _y = TimetableAxis(
        type: TimetableAxisType.time,
        list:
            editMode.value ? ttbStatus.perm.axisTime : ttbStatus.curr.axisTime,
        listStr: editMode.value
            ? ttbStatus.perm.axisTimeStr
            : ttbStatus.curr.axisTimeStr);

    TimetableAxis _z = TimetableAxis(
        type: TimetableAxisType.custom,
        list: editMode.value
            ? ttbStatus.perm.axisCustom
            : ttbStatus.curr.axisCustom,
        listStr: editMode.value
            ? ttbStatus.perm.axisCustom
            : ttbStatus.curr.axisCustom);

    _axes = TimetableAxes(x: _x, y: _y, z: _z);

    _axes.yType = TimetableAxisType.custom;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TimetableSlotDataList>.value(
          value: _slotDataList,
        ),
        ChangeNotifierProvider<TimetableAxes>.value(
          value: _axes,
        ),
      ],
      child: Flex(
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
                  axisXStr: _axes.xListStr,
                  axisYStr: _axes.yListStr,
                  axisZStr: _axes.zListStr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
