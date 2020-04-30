import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid.dart';

class TimetableDisplay extends StatelessWidget {
  final TimetableEditMode editMode;

  TimetableDisplay({
    Key key,
    this.editMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimetableEditMode>.value(
      value: editMode,
      child: LayoutBuilder(builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.all(10.0),
          child: TimetableGrid(),
        );
      }),
    );
  }
}
