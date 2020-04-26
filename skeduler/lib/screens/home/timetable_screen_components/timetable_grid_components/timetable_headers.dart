import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid_box.dart';

////////////////////////////////////////////////////////////////////////////////
/// Timetable Header X
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
      flex: 1,
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
/// Timetable Header Y & Z
////////////////////////////////////////////////////////////////////////////////

class TimetableHeaderYZ extends StatelessWidget {
  final List<String> axisY;
  final List<String> axisZ;

  const TimetableHeaderYZ({Key key, this.axisY, this.axisZ}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (axisY == null ? 0 : 1) + (axisZ == null ? 0 : 1),
      child: Flex(
        direction: Axis.vertical,
        children: _generateHeadersYZ(),
      ),
    );
  }

  List<Widget> _generateHeadersYZ() {
    List<Widget> headers = [];
    axisY.forEach((y) {
      headers.add(
        Expanded(
          flex: 1,
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              TimetableHeaderY(axisY: axisY, index: axisY.indexOf(y), flex: 1),
              TimetableHeaderZ(axisZ: axisZ),
            ],
          ),
        ),
      );
    });
    return headers;
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Timetable Header Y
////////////////////////////////////////////////////////////////////////////////

class TimetableHeaderY extends StatelessWidget {
  final List<String> axisY;
  final int index;
  final int flex;

  const TimetableHeaderY({
    Key key,
    this.axisY,
    this.index = -1,
    this.flex = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String display = axisY[index];
    return TimetableGridBox(
      context: context,
      initialDisplay: display,
      flex: flex,
      textOverFlowFade: false,
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Timetable Header Z
////////////////////////////////////////////////////////////////////////////////

class TimetableHeaderZ extends StatelessWidget {
  final List<String> axisZ;

  const TimetableHeaderZ({
    Key key,
    this.axisZ,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> colContents = [];

    axisZ.forEach((z) {
      String display = z;

      colContents.add(
        TimetableGridBox(
          context: context,
          initialDisplay: display,
          textOverFlowFade: false,
        ),
      );
    });

    return Expanded(
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        children: colContents,
      ),
    );
  }
}
