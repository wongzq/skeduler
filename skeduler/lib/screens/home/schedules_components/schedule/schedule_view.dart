import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/schedule.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/screens/home/schedules_components/schedule/schedules_expansion_tile.dart';
import 'package:skeduler/services/database_service.dart';

class ScheduleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Container()
        : StreamBuilder<List<Timetable>>(
            stream: dbService.streamGroupTimetables(groupStatus.group.docId),
            builder: (context, snapshot) {
              // timetables
              List<Timetable> timetables = snapshot.data ?? [];

              return ListView.builder(
                  itemCount: timetables.length,
                  itemBuilder: (BuildContext context, int index) {
                    return StreamBuilder<List<TimetableGroup>>(
                        stream: dbService.streamGroupTimetableGroups(
                            groupStatus.group.docId, timetables[index].docId),
                        builder: (context, snapshot) {
                          // timetable groups
                          List<TimetableGroup> timetableGroups =
                              snapshot.data ?? [];

                          List<Schedule> schedules = [];
                          for (TimetableGroup group in timetableGroups) {
                            for (TimetableGridData gridData
                                in group.gridDataList.value) {
                              if (gridData.dragData.member.docId ==
                                  groupStatus.member.docId) {
                                List<Time> scheduleTimes = generateTimes(
                                    months: List.generate(Month.values.length,
                                        (index) => Month.values[index]),
                                    weekdays: [gridData.coord.day],
                                    time: gridData.coord.time,
                                    startDate: timetables[index].startDate,
                                    endDate: timetables[index].endDate);

                                for (Time scheduleTime in scheduleTimes) {
                                  schedules.add(Schedule(
                                    available: gridData.available,
                                    day: gridData.coord.day,
                                    startTime: scheduleTime.startTime,
                                    endTime: scheduleTime.endTime,
                                    custom: gridData.coord.custom,
                                    member: gridData.dragData.member.display,
                                    subject: gridData.dragData.subject.display,
                                  ));
                                }
                              }
                            }
                          }

                          return SchedulesExpansionTile(
                              timetable: timetables[index].metadata,
                              schedules: schedules);
                        });
                  });
            });
  }
}
