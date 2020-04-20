import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_test/skeduler_timetable_2.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_test/skeduler_timetable_col.dart';

////////////////////////////////////////////////////////////////////////////////
/// Row header
////////////////////////////////////////////////////////////////////////////////

class SkedulerHeaderX extends StatelessWidget {
  final List<String> axisX;

  const SkedulerHeaderX({
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
    rowContents.add(buildBox(context, display, flex:2,));

    for (int i = 0; i < axisX.length; i++) {
      String display = axisX[i];
      rowContents.add(buildBox(context, display));
    }

    return rowContents;
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Row data
////////////////////////////////////////////////////////////////////////////////

class SkedulerRow extends StatelessWidget {
  final List<String> axisX;
  final List<String> axisY;
  final List<String> axisZ;
  final int indexY;

  const SkedulerRow({
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
    rowContents.add(SkedulerHeaderY(axisY: axisY, index: indexY));
    rowContents.add(SkedulerHeaderZ(axisZ: axisZ));

    /// Row data
    axisX.forEach((x) {
      rowContents.add(SkedulerCol(
        axisX: axisX,
        axisY: axisY,
        axisZ: axisZ,
        indexX: axisX.indexOf(x),
        indexY: indexY,
      ));
    });

    return Expanded(
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        children: rowContents,
      ),
    );
  }
}
