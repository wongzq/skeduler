import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid_box.dart';

class TimetableSlots extends StatelessWidget {
  final List<String> axisXStr;
  final List<String> axisYStr;
  final List<String> axisZStr;

  final List<Weekday> axisDay;
  final List<Time> axisTime;
  final List<String> axisCustom;

  const TimetableSlots({
    Key key,
    this.axisXStr,
    this.axisYStr,
    this.axisZStr,
    this.axisDay,
    this.axisTime,
    this.axisCustom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: axisXStr == null ? 0 : axisXStr.length,
      child: Flex(
        direction: Axis.horizontal,
        children: () {
          List<Widget> cols = [];

          for (int x = 0; x < axisXStr.length; x++) {
            List<Widget> rows = [];

            for (int y = 0; y < axisYStr.length; y++) {
              for (int z = 0; z < axisZStr.length; z++) {
                String display = '-';

                rows.add(TimetableGridBox(
                  context: context,
                  initialDisplay: display,
                  type: GridBoxType.content,
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
