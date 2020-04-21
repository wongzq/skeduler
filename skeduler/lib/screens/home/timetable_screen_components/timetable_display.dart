import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid.dart';

class TimetableDisplay extends StatefulWidget {
  @override
  _TimetableDisplayState createState() => _TimetableDisplayState();
}

class _TimetableDisplayState extends State<TimetableDisplay> {
  @override
  Widget build(BuildContext context) {
    List<String> axis1 = [
      'YR 1',
      'YR 2',
      'YR 3',
      'YR 4',
      'YR 5',
      'YR 6',
    ];
    List<String> axis2 = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    List<String> axis3 = ['1500 1630', '1630 1800'];

    return TimetableGrid(
      axisX: axis1,
      axisY: axis2,
      axisZ: axis3,
    );
  }
}
