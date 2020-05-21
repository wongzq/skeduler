import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/schedule.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

class ScheduleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return StreamBuilder<Object>(
      stream: dbService.streamGroupTimetables(groupStatus.group.docId),
      builder: (context, snapshot) {
        List<Timetable> timetables =
            snapshot != null ? snapshot.data ?? [] : [];

        List<Schedule> schedules = [];

        timetables.forEach((timetable) {
          timetable.gridDataList.value.forEach((gridData) {
            if (gridData.dragData.member.display == groupStatus.me.display) {
              List<Time> scheduleTimes = generateTimes(
                months: List.generate(
                  Month.values.length,
                  (index) => Month.values[index],
                ),
                weekDays: [gridData.coord.day],
                time: gridData.coord.time,
                startDate: timetable.startDate,
                endDate: timetable.endDate,
              );

              scheduleTimes.forEach((scheduleTime) {
                schedules.add(
                  Schedule(
                    day: gridData.coord.day,
                    startTime: scheduleTime.startTime,
                    endTime: scheduleTime.endTime,
                    custom: gridData.coord.custom,
                    member: gridData.dragData.member.display ?? '',
                    subject: gridData.dragData.subject.display ?? '',
                  ),
                );
              });
            }
          });
        });

        schedules.sort((a, b) => a.date.compareTo(b.date));

        return schedules.length <= 0
            ? Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'You haven\'t been scheduled',
                  style: textStyleBody.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : ListView.builder(
                controller: ScrollController(),
                physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  bool scheduleIsToday =
                      schedules[index].date.year == DateTime.now().year &&
                          schedules[index].date.month == DateTime.now().month &&
                          schedules[index].date.day == DateTime.now().day;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      index == 0 ||
                              (index > 0 &&
                                  schedules[index].monthStr !=
                                      schedules[index - 1].monthStr)
                          ? Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    schedules[index].monthStr.toUpperCase(),
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
                      Container(
                        color: scheduleIsToday
                            ? getOriginThemeData(
                                    ThemeProvider.themeOf(context).id)
                                .primaryColorLight
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 0.0, 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    schedules[index].custom +
                                            ' : ' +
                                            schedules[index].subject ??
                                        '',
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
                                    schedules[index].dayStr +
                                        ', ' +
                                        schedules[index].dateStr,
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
                            Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: scheduleIsToday
                                        ? Theme.of(context)
                                            .scaffoldBackgroundColor
                                        : getOriginThemeData(
                                                ThemeProvider.themeOf(context)
                                                    .id)
                                            .primaryColorLight,
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  child: Text(
                                    schedules[index].startTimeStr,
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
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    'to',
                                    style: TextStyle(
                                      color:
                                          scheduleIsToday ? Colors.black : null,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: scheduleIsToday
                                        ? Theme.of(context)
                                            .scaffoldBackgroundColor
                                        : getOriginThemeData(
                                                ThemeProvider.themeOf(context)
                                                    .id)
                                            .primaryColorLight,
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  child: Text(
                                    schedules[index].endTimeStr,
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
                      ),
                      Divider(height: 1.0),
                    ],
                  );
                },
              );
      },
    );
  }
}
