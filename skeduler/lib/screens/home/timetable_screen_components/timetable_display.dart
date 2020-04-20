import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_test/skeduler_timetable_2.dart';

class TimetableDisplay extends StatefulWidget {
  @override
  _TimetableDisplayState createState() => _TimetableDisplayState();
}

class _TimetableDisplayState extends State<TimetableDisplay> {
  @override
  Widget build(BuildContext context) {
    List<String> axis1 = ['YR1', 'YR2', 'YR3', 'YR4', 'YR5', 'YR6'];
    List<String> axis2 = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    List<String> axis3 = ['1500 1630', '1630 1800'];
    
    return SkedulerTimetable2(
      axisX: axis1,
      axisY: axis2,
      axisZ: axis3,
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Testing 1
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

    for (int xz = -1; xz < widget.axisX.length * widget.axisZ.length; xz++) {
      int x = xz ~/ widget.axisZ.length;
      int z = xz % widget.axisZ.length;

      List<Widget> tableRowChildren = [];

      for (int y = -1; y < widget.axisY.length; y++) {
        String display;
        if (xz == -1 && y == -1) {
          display = 'Switch';
        } else if (xz != -1 && y == -1) {
          display = widget.axisX[x] + ' ' + widget.axisZ[z];
        } else if (xz == -1 && y != -1) {
          display = widget.axisY[y];
        } else {
          display = widget.axisX[x] + widget.axisY[y] + widget.axisZ[z];
        }

        tableRowChildren.add(SkedulerTimetableBox(display: display));
      }

      TableRow tableRow = TableRow(children: tableRowChildren);

      tableRows.add(tableRow);
    }

    return tableRows;
  }
}

class SkedulerTimetableBox extends StatelessWidget {
  final String display;

  const SkedulerTimetableBox({Key key, this.display}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).primaryColorDark,
        ),
        child: Text(
          display ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.0),
        ),
      ),
    );
  }
}
