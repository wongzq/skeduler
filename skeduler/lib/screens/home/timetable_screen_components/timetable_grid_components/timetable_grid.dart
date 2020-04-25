import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_row.dart';

class TimetableGrid extends StatelessWidget {
  /// properties
  final List<String> axisX;
  final List<String> axisY;
  final List<String> axisZ;

  final bool editMode;

  /// constructors
  const TimetableGrid({
    Key key,
    this.axisX = const [],
    this.axisY = const [],
    this.axisZ = const [],
    this.editMode = false,
  }) : super(key: key);

  /// methods
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ValueNotifier<bool>(editMode),
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        children: _generateRows(context),
      ),
    );
  }

  List<Widget> _generateRows(BuildContext context) {
    List<Widget> rows = [];

    rows.add(TimetableHeaderX(axisX: axisX));

    rows += List.generate(
      axisY.length,
      (index) => TimetableRow(
        axisX: axisX,
        axisY: axisY,
        axisZ: axisZ,
        indexY: index,
      ),
    );

    return rows;
  }
}
