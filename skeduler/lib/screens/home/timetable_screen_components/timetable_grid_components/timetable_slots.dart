import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid_box.dart';

class TimetableSlots extends StatelessWidget {
  final List<String> axisX;
  final List<String> axisY;
  final List<String> axisZ;

  const TimetableSlots({
    Key key,
    this.axisX,
    this.axisY,
    this.axisZ,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: axisX == null ? 0 : axisX.length,
      child: Flex(
        direction: Axis.horizontal,
        children: () {
          List<Widget> cols = [];

          for (int x = 0; x < axisX.length; x++) {
            List<Widget> rows = [];

            for (int y = 0; y < axisY.length; y++) {
              for (int z = 0; z < axisZ.length; z++) {
                String display = '-';

                rows.add(TimetableGridBox(
                  context: context,
                  initialDisplay: display,
                  content: true,
                ));
              }
            }

            cols.add(Expanded(
              flex: 1,
              child: Flex(
                direction: Axis.vertical,
                children: rows,
              ),
            ));
          }

          return cols;
        }(),
      ),
    );
  }
}
