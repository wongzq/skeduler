import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_test/skeduler_timetable_2.dart';

class SkedulerHeaderY extends StatelessWidget {
  final List<String> axisY;
  final int index;

  const SkedulerHeaderY({
    Key key,
    this.axisY,
    this.index = -1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String display = axisY[index];
    return buildBox(context, display);
  }
}

class SkedulerHeaderZ extends StatelessWidget {
  final List<String> axisZ;

  const SkedulerHeaderZ({
    Key key,
    this.axisZ,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> colContents = [];

    axisZ.forEach((z) {
      String display = z;

      colContents.add(buildBox(context, display));
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

class SkedulerCol extends StatelessWidget {
  final List<String> axisX;
  final List<String> axisY;
  final List<String> axisZ;
  final int indexX;
  final int indexY;

  const SkedulerCol({
    Key key,
    this.axisX,
    this.axisY,
    this.axisZ,
    this.indexX = -1,
    this.indexY = -1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> colContents = [];

    axisZ.forEach((z) {
      // String display = axisX[indexX] + axisY[indexY] + z;
      String display = '-';

      colContents.add(buildBox(context, display, content: true));
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
