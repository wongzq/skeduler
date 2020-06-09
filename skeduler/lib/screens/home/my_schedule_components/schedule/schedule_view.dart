import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/schedule.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/screens/home/my_schedule_components/schedule/schedule_month_expansion_tile.dart';
import 'package:skeduler/services/database_service.dart';

class ScheduleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Container()
        : StreamBuilder<Object>(
            stream: dbService.streamGroupTimetables(groupStatus.group.docId),
            builder: (context, snapshot) {
              List<Timetable> timetables =
                  snapshot != null ? snapshot.data ?? [] : [];

              List<Schedule> schedules = [];

              for (Timetable timetable in timetables) {
                for (TimetableGridData gridData
                    in timetable.gridDataList.value) {
                  if (gridData.dragData.member.docId ==
                      groupStatus.member.docId) {
                    List<Time> scheduleTimes = generateTimes(
                      months: List.generate(
                        Month.values.length,
                        (index) => Month.values[index],
                      ),
                      weekdays: [gridData.coord.day],
                      time: gridData.coord.time,
                      startDate: timetable.startDate,
                      endDate: timetable.endDate,
                    );

                    scheduleTimes.forEach((scheduleTime) {
                      schedules.add(
                        Schedule(
                          available: gridData.available,
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
                }
              }

              schedules.sort((a, b) => a.date.compareTo(b.date));

              Map<int, List<Schedule>> schedulesMonths = {};

              for (Schedule schedule in schedules) {
                if (schedulesMonths.containsKey(schedule.date.month)) {
                  schedulesMonths[schedule.date.month].add(schedule);
                } else {
                  schedulesMonths[schedule.date.month] = [];
                  schedulesMonths[schedule.date.month].add(schedule);
                }
              }

              return schedules.length <= 0
                  ? Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'NO SCHEDULES FOUND',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                              // fontStyle: FontStyle.italic,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        Divider(height: 1.0),
                      ],
                    )
                  : ListView.builder(
                      controller: ScrollController(),
                      physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: schedulesMonths.length + 1,
                      itemBuilder: (context, index) {
                        int monthIndex = index >= schedulesMonths.length
                            ? -1
                            : schedulesMonths.keys.elementAt(index);

                        return index >= schedulesMonths.length
                            ? SizedBox(height: 100.0)
                            : ScheduleMonthExpansionTile(
                                monthIndex: monthIndex,
                                schedules: schedulesMonths[monthIndex],
                              );
                      },
                    );
            },
          );
  }
}
