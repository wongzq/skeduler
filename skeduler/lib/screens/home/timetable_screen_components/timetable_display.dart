import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid.dart';

class TimetableDisplay extends StatelessWidget {
  final Timetable timetable;

  const TimetableDisplay({Key key, this.timetable}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<String> axis1 = timetable.axisDaysShortStr ?? [];
    List<String> axis2 = timetable.axisTimesStr ?? [];
    List<String> axis3 = timetable.axisCustom ?? [];

    return TimetableGrid(
      axisX: axis1,
      axisY: axis2,
      axisZ: axis3,
    );
  }
}
