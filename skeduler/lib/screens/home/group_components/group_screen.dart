import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/conflict.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/navigation/home_drawer.dart';
import 'package:skeduler/screens/home/group_components/conflicts/conflict_list_tile.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_owner.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_admin.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_member.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class GroupScreen extends StatefulWidget {
  final void Function({String groupName}) refresh;

  const GroupScreen({Key key, this.refresh}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<Conflict> _generateConflicts({
    @required List<Member> members,
    @required List<Timetable> timetables,
  }) {
    List<Conflict> conflicts = [];

    // for each timetable
    for (Timetable timetable in timetables) {

      // for each timetable grid data
      for (TimetableGridData gridData in timetable.gridDataList.value) {
        // if grid data is not available and has member assigned
        if (gridData.available == false &&
            gridData.dragData.member.docId != null &&
            gridData.dragData.member.docId.trim() != '') {
          // list of conflict dates for this gridData
          List<DateTime> conflictDates = [];

          // find member
          Member member = members.firstWhere(
            (test) => test.docId == gridData.dragData.member.docId,
            orElse: () => null,
          );

          // get timetable times
          List<Time> timetableTimes = generateTimes(
            months: List.generate(
              Month.values.length,
              (index) => Month.values[index],
            ),
            weekdays: [gridData.coord.day],
            time: gridData.coord.time,
            startDate: timetable.startDate,
            endDate: timetable.endDate,
          );

          // if member found
          if (member != null) {
            // get member times
            List<Time> memberTimes = member.alwaysAvailable
                ? member.timesUnavailable
                : member.timesAvailable;

            // for each timetable time
            for (Time timetableTime in timetableTimes) {
              bool availableTimeFound = false;

              // for each member time
              for (Time memberTime in memberTimes) {
                // if member is always available, check unavailable times
                // if timetableTime is within unavailable times, member is not available
                if (member.alwaysAvailable &&
                    !timetableTime.notWithinDateTimeOf(memberTime)) {
                  conflictDates.add(timetableTime.startDate);
                  break;
                }
                // if member is not always available, check available times
                // if timetableTime is not within available times, member is not available
                else if (!member.alwaysAvailable &&
                    timetableTime.withinDateTimeOf(memberTime)) {
                  availableTimeFound = true;
                  break;
                }
              }

              if (!member.alwaysAvailable && !availableTimeFound) {
                conflictDates.add(timetableTime.startDate);
              }
            }
          } else {
            for (Time timetableTime in timetableTimes) {
              conflictDates.add(timetableTime.startDate);
            }
          }

          conflicts.add(
            Conflict(
              conflictDates: conflictDates,
              gridData: gridData,
              timetable: TimetableMetadata(
                docId: timetable.docId,
                startDate: Timestamp.fromDate(timetable.startDate),
                endDate: Timestamp.fromDate(timetable.endDate),
              ),
              member: MemberMetadata(
                docId: member.docId,
                name: member.name,
                nickname: member.nickname,
              ),
            ),
          );
        }
      }
    }

    return conflicts;
  }

  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);

    return groupStatus.group == null
        ? Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: AppBarTitle(title: 'Group'),
                ),
                drawer: HomeDrawer(DrawerEnum.group),
              ),
              Loading(),
            ],
          )
        : Scaffold(
            appBar: AppBar(
              title: AppBarTitle(
                title: groupStatus.group.name,
                alternateTitle: 'Admin Panel',
                subtitle: 'Admin Panel',
              ),
            ),
            drawer: HomeDrawer(DrawerEnum.group),
            floatingActionButton: groupStatus.me != null
                ? () {
                    if (groupStatus.me.role == MemberRole.owner)
                      return GroupScreenOptionsOwner();
                    else if (groupStatus.me.role == MemberRole.admin)
                      return GroupScreenOptionsAdmin();
                    else if (groupStatus.me.role == MemberRole.member)
                      return GroupScreenOptionsMember();
                    else
                      return Container();
                  }()
                : Container(),
            body: StreamBuilder<List<Timetable>>(
              stream: dbService.streamGroupTimetables(groupStatus.group.docId),
              builder: (context, snapshot) {
                List<Timetable> timetables =
                    snapshot != null ? snapshot.data ?? [] : [];

                List<Conflict> conflicts = _generateConflicts(
                  members: groupStatus.members,
                  timetables: timetables,
                );

                return ListView.builder(
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: conflicts.length,
                  itemBuilder: (context, index) {
                    return ConflictListTile(
                      conflict: conflicts[index],
                    );
                  },
                );
              },
            ),
          );
  }
}
