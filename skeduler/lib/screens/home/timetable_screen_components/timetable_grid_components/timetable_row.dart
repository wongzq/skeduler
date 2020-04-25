import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_col.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid_box.dart';

////////////////////////////////////////////////////////////////////////////////
/// Row header
////////////////////////////////////////////////////////////////////////////////

class TimetableHeaderX extends StatelessWidget {
  final List<String> axisX;

  const TimetableHeaderX({
    Key key,
    this.axisX = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        children: _generateRow(context),
      ),
    );
  }

  List<Widget> _generateRow(BuildContext context) {
    List<Widget> rowContents = [];

    /// Add Switch button
    String display = 'SWITCH';
    rowContents.add(
        TimetableGridBox(context: context, initialDisplay: display, flex: 2));

    for (int i = 0; i < axisX.length; i++) {
      String display = axisX[i];
      rowContents.add(
          TimetableGridBox(context: context, initialDisplay: display, flex: 1));
    }

    return rowContents;
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Row data
////////////////////////////////////////////////////////////////////////////////

class TimetableRow extends StatelessWidget {
  final List<String> axisX;
  final List<String> axisY;
  final List<String> axisZ;
  final int indexY;

  const TimetableRow({
    Key key,
    this.axisX = const [],
    this.axisY = const [],
    this.axisZ = const [],
    this.indexY = -1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> rowContents = [];

    /// Row header
    if (axisY != null && axisY.isNotEmpty) {
      if (axisZ != null && axisZ.isNotEmpty) {
        rowContents.add(TimetableHeaderY(axisY: axisY, index: indexY, flex: 1));
        rowContents.add(TimetableHeaderZ(axisZ: axisZ));
      } else {
        rowContents.add(TimetableHeaderY(axisY: axisY, index: indexY, flex: 2));
      }
    }

    /// Row data
    axisX.forEach((x) {
      rowContents.add(TimetableCol(
        axisX: axisX,
        axisY: axisY,
        axisZ: axisZ,
        indexX: axisX.indexOf(x),
        indexY: indexY,
      ));
    });

    return Expanded(
      flex: axisZ != null && axisZ.isNotEmpty ? axisZ.length : 1,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        children: rowContents,
      ),
    );
  }
}
