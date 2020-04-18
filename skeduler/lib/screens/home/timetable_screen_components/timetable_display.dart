import 'package:flutter/material.dart';

class TimetableDisplay extends StatefulWidget {
  @override
  _TimetableDisplayState createState() => _TimetableDisplayState();
}

class _TimetableDisplayState extends State<TimetableDisplay> {
  List<String> axisNumber = ['1', '2', '3', '4', '5'];
  List<String> axisLetter = ['A', 'B', 'C', 'D'];
  List<String> axisCharac = ['!', '@', '#'];

  @override
  Widget build(BuildContext context) {
    return SkedulerTimetable(
      axisX: axisNumber,
      axisY: axisLetter,
      axisZ: axisCharac,
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Testing
////////////////////////////////////////////////////////////////////////////////

class SkedulerTimetable extends StatefulWidget {
  final List<String> axisX;
  final List<String> axisY;
  final List<String> axisZ;

  const SkedulerTimetable({
    Key key,
    @required this.axisX,
    @required this.axisY,
    @required this.axisZ,
  }) : super(key: key);

  @override
  _SkedulerTimetableState createState() => _SkedulerTimetableState();
}

class _SkedulerTimetableState extends State<SkedulerTimetable> {
  @override
  Widget build(BuildContext context) {
    return Table(
      children: _generateRows(),
    );
  }

  List<TableRow> _generateRows() {
    List<TableRow> tableRows = [];

    for (int x = 0; x < widget.axisX.length; x++) {
      List<Widget> tableRowChildren = [];

      for (int y = 0; y < widget.axisY.length; y++) {
        tableRowChildren.add(Text(widget.axisY[y]));
      }

      TableRow tableRow = TableRow(
        children: tableRowChildren,
      );

      tableRows.add(tableRow);
    }

    return tableRows;
  }
}
