import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/schedule.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/models/group_data/timetable.dart';
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
              generateTimes(
                months: List.generate(
                  Month.values.length,
                  (index) => Month.values[index],
                ),
                weekDays: [gridData.coord.day],
                time: gridData.coord.time,
                startDate: timetable.startDate,
                endDate: timetable.endDate,
              ).forEach((scheduleTime) {
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

        return ListView.builder(
          controller: ScrollController(),
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                index == 0 ||
                        (index > 0 &&
                            schedules[index].month !=
                                schedules[index - 1].month)
                    ? Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              schedules[index].month.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16.0,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                          Divider(thickness: 1.0),
                        ],
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            schedules[index].custom +
                                    ' : ' +
                                    schedules[index].subject ??
                                '',
                            style: textStyleBody.copyWith(fontSize: 15.0),
                            overflow: TextOverflow.fade,
                          ),
                          Text(
                            schedules[index].day + ', ' + schedules[index].date,
                            style: textStyleBodyLight.copyWith(
                              color: Theme.of(context).brightness ==
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
                            color: getOriginThemeData(
                                    ThemeProvider.themeOf(context).id)
                                .primaryColorLight,
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: Text(
                            schedules[index].startTime,
                            style: TextStyle(
                              color: Colors.black,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text('to'),
                        ),
                        Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: getOriginThemeData(
                                    ThemeProvider.themeOf(context).id)
                                .primaryColorLight,
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: Text(
                            schedules[index].endTime,
                            style: TextStyle(
                              color: Colors.black,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(width: 20.0),
                      ],
                    ),
                  ],
                ),
                Divider(thickness: 1.0),
              ],
            );
          },
        );
      },
    );
  }
}
