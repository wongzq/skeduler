import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/schedule.dart';
import 'package:skeduler/models/auxiliary/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/screens/home/schedules_components/schedule/schedules_expansion_tile.dart';

class ScheduleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    // list of all schedules
    List<List<Schedule>> schedulesList =
        groupStatus.timetables.map((timetable) {
      // index of timetable
      int index = groupStatus.timetables.indexOf(timetable);
      List<Schedule> schedules = [];
      List<TimetableGroup> timetableGroups =
          groupStatus.timetables[index].groups;

      for (TimetableGroup group in timetableGroups) {
        for (TimetableGridData gridData in group.gridDataList.value) {
          if (gridData.dragData.member.docId == groupStatus.member.docId) {
            List<Time> scheduleTimes = Time.generateTimes(
                months: List.generate(
                    Month.values.length, (index) => Month.values[index]),
                weekdays: [gridData.coord.day],
                time: gridData.coord.time,
                startDate: groupStatus.timetables[index].startDate,
                endDate: groupStatus.timetables[index].endDate);

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

      schedules.sort((a, b) => a.date.compareTo(b.date));

      return schedules;
    }).toList();

    // check if there are schedules
    bool noSchedules = schedulesList.firstWhere(
            (schedules) => schedules.isNotEmpty,
            orElse: () => null) ==
        null;

    return groupStatus.group == null
        ? Container()
        : groupStatus.timetables.length == 0 || noSchedules
            ? Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text('NO SCHEDULES FOUND',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                            letterSpacing: 2.0))),
                Divider(height: 1.0)
              ])
            : ListView.builder(
                itemCount: groupStatus.timetables.length,
                itemBuilder: (BuildContext context, int index) {
                  return SchedulesExpansionTile(
                      timetable: groupStatus.timetables[index].metadata,
                      schedules: schedulesList[index]);
                });
  }
}
