import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_headers.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_slots.dart';

class TimetableGrid extends StatefulWidget {
  /// properties
  final Timetable timetable;

  /// constructors
  TimetableGrid({
    Key key,
    this.timetable,
  }) : super(key: key);

  @override
  _TimetableGridState createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  List<String> axisX;
  List<String> axisY;
  List<String> axisZ;

  /// methods
  List<Widget> _generateRows(BuildContext context) {
    List<Widget> gridStruct = [];

    gridStruct.add(TimetableHeaderX(axisX: axisX));

    gridStruct.add(
      Expanded(
        flex: (axisY.length ?? 0) * (axisZ.length ?? 0),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            TimetableHeaderYZ(axisY: axisY, axisZ: axisZ),
            TimetableSlots(axisX: axisX, axisY: axisY, axisZ: axisZ),
          ],
        ),
      ),
    );

    return gridStruct;
  }

  @override
  void initState() {
    if (widget.timetable != null) {
      axisX = widget.timetable.axisDayShortStr;
      axisY = widget.timetable.axisTimeStr;
      axisZ = widget.timetable.axisCustom;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimetableGridDataList>(
      create: (_) => TimetableGridDataList(),
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        children: _generateRows(context),
      ),
    );
  }
}
