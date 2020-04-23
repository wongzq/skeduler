import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid.dart';

class TimetableDisplay extends StatefulWidget {
  final Timetable timetable;

  const TimetableDisplay({Key key, this.timetable}) : super(key: key);

  @override
  _TimetableDisplayState createState() => _TimetableDisplayState();
}

class _TimetableDisplayState extends State<TimetableDisplay> {
  @override
  Widget build(BuildContext context) {
    List<String> axis1 = widget.timetable.axisDaysShortStr ?? [];
    List<String> axis2 = widget.timetable.axisTimesStr ?? [];
    List<String> axis3 = widget.timetable.axisCustom ?? [];

    return TimetableGrid(
      axisX: axis1,
      axisY: axis2,
      axisZ: axis3,
    );
  }
}
