import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid_box.dart';

////////////////////////////////////////////////////////////////////////////////
/// Col header
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
        context: context, initialDisplay: display, flex: flex);
  }
}

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

      colContents
          .add(TimetableGridBox(context: context, initialDisplay: display));
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

////////////////////////////////////////////////////////////////////////////////
/// Col header
////////////////////////////////////////////////////////////////////////////////

class TimetableCol extends StatelessWidget {
  final List<String> axisX;
  final List<String> axisY;
  final List<String> axisZ;
  final int indexX;
  final int indexY;

  const TimetableCol({
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

    if (axisZ != null && axisZ.isNotEmpty) {
      axisZ.forEach((z) {
        String display = '-';

        colContents.add(TimetableGridBox(
            context: context, initialDisplay: display, content: true));
      });
    } else {
      String display = '-';
      colContents.add(TimetableGridBox(
          context: context, initialDisplay: display, content: true));
    }

    return Expanded(
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        children: colContents,
      ),
    );
  }
}
