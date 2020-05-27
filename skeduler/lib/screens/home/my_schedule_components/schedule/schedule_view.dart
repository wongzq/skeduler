import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/schedule.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/screens/home/my_schedule_components/schedule/schedule_list_tile.dart';
import 'package:skeduler/services/database_service.dart';

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
            if (gridData.dragData.member.docId == groupStatus.me.docId) {
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
                physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  bool scheduleIsToday =
                      schedules[index].date.year == DateTime.now().year &&
                          schedules[index].date.month == DateTime.now().month &&
                          schedules[index].date.day == DateTime.now().day;

                  return ScheduleListTile(
                    scheduleIsToday: scheduleIsToday,
                    index: index,
                    schedule: schedules[index],
                    prevSchedule: index > 0 ? schedules[index - 1] : null,
                  );
                },
              );
      },
    );
  }
}
