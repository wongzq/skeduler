import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_test/skeduler_timetable_row.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

class SkedulerTimetable2 extends StatelessWidget {
  final List<String> axisX;
  final List<String> axisY;
  final List<String> axisZ;

  const SkedulerTimetable2({
    Key key,
    this.axisX = const [],
    this.axisY = const [],
    this.axisZ = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.max,
      children: _generateRows(context),
    );
  }

  List<Widget> _generateRows(BuildContext context) {
    List<Widget> rows = [];

    rows.add(SkedulerHeaderX(axisX: axisX));

    rows += List.generate(
      axisY.length,
      (index) => SkedulerRow(
        axisX: axisX,
        axisY: axisY,
        axisZ: axisZ,
        indexY: index,
      ),
    );

    return rows;
  }
}

Widget buildBox(
  BuildContext context,
  String display, {
  int flex = 1,
  bool content = false,
}) {
  return Expanded(
    flex: flex,
    child: Padding(
      padding: EdgeInsets.all(2.0),
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: content
              ? getOriginThemeData(ThemeProvider.themeOf(context).id)
                  .primaryColorLight
              : getOriginThemeData(ThemeProvider.themeOf(context).id)
                  .primaryColor
        ),
        child: Text(
          display ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 10.0),
        ),
      ),
    ),
  );
}
