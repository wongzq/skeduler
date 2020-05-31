import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/schedule.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/screens/home/my_schedule_components/schedule/schedule_list_tile.dart';

class ScheduleMonthExpansionTile extends StatelessWidget {
  final int monthIndex;
  final List<Schedule> schedules;

  const ScheduleMonthExpansionTile({
    Key key,
    @required this.monthIndex,
    @required this.schedules,
  }) : super(key: key);

  bool _memberIsAvailableAtThisTime(BuildContext context, Schedule schedule) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    Time scheduleTime = Time(
      startTime: schedule.startTime,
      endTime: schedule.endTime,
    );

    List<Time> times = groupStatus.me.alwaysAvailable
        ? groupStatus.me.timesUnavailable
        : groupStatus.me.timesAvailable;

    for (Time time in times) {
      if (groupStatus.me.alwaysAvailable &&
          !scheduleTime.notWithinDateTimeOf(time)) {
        return false;
      } else if (!groupStatus.me.alwaysAvailable &&
          scheduleTime.withinDateTimeOf(time)) {
        return true;
      }
    }

    return groupStatus.me.alwaysAvailable;
  }

  List<Widget> _generateScheduleListTiles(BuildContext context) {
    List<Widget> scheduleWidgets = [];

    for (Schedule schedule in schedules) {
      bool scheduleIsToday = schedule.date.year == DateTime.now().year &&
          schedule.date.month == DateTime.now().month &&
          schedule.date.day == DateTime.now().day;

      scheduleWidgets.add(
        Theme(
          data: Theme.of(context),
          child: ScheduleListTile(
            scheduleIsToday: scheduleIsToday,
            schedule: schedule,
          ),
        ),
      );
    }

    return scheduleWidgets;
  }

  @override
  Widget build(BuildContext context) {
    int unavailableCount = 0;

    for (Schedule schedule in schedules) {
      unavailableCount = _memberIsAvailableAtThisTime(context, schedule)
          ? unavailableCount
          : unavailableCount + 1;
    }

    return Column(
      children: <Widget>[
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            accentColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          child: ExpansionTile(
            initiallyExpanded: DateTime.now().month == monthIndex,
            title: Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    unavailableCount > 0 ? Icons.warning : null,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    getMonthStr(Month.values[monthIndex - 1]).toUpperCase(),
                    style: TextStyle(
                      fontSize: 16.0,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            children: _generateScheduleListTiles(context),
          ),
        ),
        Divider(height: 1.0),
      ],
    );
  }
}
