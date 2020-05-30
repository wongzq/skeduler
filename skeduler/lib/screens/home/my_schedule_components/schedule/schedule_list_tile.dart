import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/schedule.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/shared/ui_settings.dart';

class ScheduleListTile extends StatelessWidget {
  final bool scheduleIsToday;
  final int index;
  final Schedule schedule;
  final Schedule prevSchedule;

  ScheduleListTile({
    Key key,
    @required this.scheduleIsToday,
    @required this.index,
    @required this.schedule,
    @required this.prevSchedule,
  }) : super(key: key);

  // methods
  bool _memberIsAvailableAtThisTime(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    Time scheduleTime =
        Time(startTime: schedule.startTime, endTime: schedule.endTime);

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

  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Display Month
        index == 0 ||
                (prevSchedule == null
                    ? false
                    : index > 0 && schedule.monthStr != prevSchedule.monthStr)
            ? Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      schedule.monthStr.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.0,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  Divider(height: 1.0),
                ],
              )
            : Container(),

        // Custom List Tile
        Container(
          color: scheduleIsToday ? originTheme.primaryColorLight : null,
          child: Column(
            children: [
              schedule.available
                  ? Container()
                  : _memberIsAvailableAtThisTime(context)
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              schedule.available ? null : Icons.warning,
                              color: scheduleIsToday ? Colors.red : Colors.grey,
                            ),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'You are not available at this time',
                                style: TextStyle(
                                  color: scheduleIsToday
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            Icon(
                              schedule.available ? null : Icons.warning,
                              color: scheduleIsToday ? Colors.red : Colors.grey,
                            ),
                          ],
                        ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left section
                  // Display Custom : Subjects
                  // Display Weekday, Day Month
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        20.0, schedule.available ? 15.0 : 5.0, 0.0, 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          schedule.custom + ' : ' + schedule.subject ?? '',
                          style: scheduleIsToday
                              ? textStyleBody.copyWith(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                )
                              : textStyleBody.copyWith(
                                  fontSize: 15.0,
                                ),
                          overflow: TextOverflow.fade,
                        ),
                        Text(
                          schedule.dayStr,
                          style: textStyleBodyLight.copyWith(
                            color: scheduleIsToday
                                ? Colors.grey.shade700
                                : Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.shade600
                                    : Colors.grey,
                            fontSize: 13.0,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                        Text(
                          schedule.dateStr,
                          style: textStyleBodyLight.copyWith(
                            color: scheduleIsToday
                                ? Colors.grey.shade700
                                : Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.shade600
                                    : Colors.grey,
                            fontSize: 13.0,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                      ],
                    ),
                  ),

                  // Right section
                  // Display Start Time to End Time
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: scheduleIsToday
                              ? Theme.of(context).scaffoldBackgroundColor
                              : originTheme.primaryColorLight,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Text(
                          schedule.startTimeStr,
                          style: TextStyle(
                            color: scheduleIsToday
                                ? Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white
                                : Colors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(7.5),
                        child: Text(
                          'to',
                          style: TextStyle(
                            color: scheduleIsToday ? Colors.black : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: scheduleIsToday
                              ? Theme.of(context).scaffoldBackgroundColor
                              : originTheme.primaryColorLight,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Text(
                          schedule.endTimeStr,
                          style: TextStyle(
                            color: scheduleIsToday
                                ? Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white
                                : Colors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1.0),
      ],
    );
  }
}
