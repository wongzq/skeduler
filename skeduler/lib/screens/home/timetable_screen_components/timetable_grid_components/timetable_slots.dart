import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid_box.dart';

class TimetableSlots extends StatelessWidget {
  final TimetableAxisType xType;
  final TimetableAxisType yType;
  final TimetableAxisType zType;

  final List xList;
  final List yList;
  final List zList;

  final List<String> xListStr;
  final List<String> yListStr;
  final List<String> zListStr;

  const TimetableSlots({
    Key key,
    @required this.xType,
    @required this.yType,
    @required this.zType,
    @required this.xList,
    @required this.yList,
    @required this.zList,
    @required this.xListStr,
    @required this.yListStr,
    @required this.zListStr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: xListStr == null ? 0 : xListStr.length,
      child: Flex(
        direction: Axis.horizontal,
        children: () {
          List<Widget> cols = [];

          for (int x = 0; x < xListStr.length; x++) {
            List<Widget> rows = [];

            for (int y = 0; y < yListStr.length; y++) {
              for (int z = 0; z < zListStr.length; z++) {
                dynamic getAxisVal(TimetableAxisType axisType) =>
                    xType == axisType
                        ? xList[x]
                        : yType == axisType
                            ? yList[y]
                            : zType == axisType ? zList[z] : null;

                Weekday dayVal = getAxisVal(TimetableAxisType.day);
                Time timeVal = getAxisVal(TimetableAxisType.time);
                String customVal = getAxisVal(TimetableAxisType.custom);

                rows.add(TimetableGridBox(
                  gridBoxType: GridBoxType.content,
                  coord: TimetableCoord(
                    day: dayVal,
                    time: timeVal,
                    custom: customVal,
                  ),
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
