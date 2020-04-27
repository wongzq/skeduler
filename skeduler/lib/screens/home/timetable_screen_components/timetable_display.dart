import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid.dart';

class TimetableDisplay extends StatelessWidget {
  final bool editMode;

  TimetableDisplay({
    Key key,
    this.editMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditModeBool>(
      create: (_) => EditModeBool(value: this.editMode),
      child: LayoutBuilder(builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.all(10.0),
          child: TimetableGrid(),
        );
      }),
    );
  }
}
