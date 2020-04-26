import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid.dart';

class TimetableDisplay extends StatelessWidget {
  final Timetable timetable;
  final bool editMode;

  TimetableDisplay({
    Key key,
    this.timetable,
    this.editMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List<String> axis1 = timetable.axisDayShortStr ?? [];
    // List<String> axis2 = timetable.axisTimeStr ?? [];
    // List<String> axis3 = timetable.axisCustom ?? [];

    return ChangeNotifierProvider<EditModeBool>(
      create: (_) => EditModeBool(value: this.editMode),
      child: LayoutBuilder(builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.all(10.0),
          child: TimetableGrid(timetable: timetable),
        );
      }),
    );
  }
}
