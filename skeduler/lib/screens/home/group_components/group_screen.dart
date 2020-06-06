import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/conflict.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/navigation/home_drawer.dart';
import 'package:skeduler/screens/home/group_components/conflicts/conflict_list_tile.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_owner.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_admin.dart';
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
  OriginTheme _originTheme;

  bool _showIgnored = false;
  ConflictSort _sortBy = ConflictSort.date;

  List<Widget> _generateActions() {
    return [
      PopupMenuButton(
        icon: Icon(Icons.sort),
        itemBuilder: (context) => [
          PopupMenuItem(value: ConflictSort.date, child: Text('Sort by date')),
          PopupMenuItem(
              value: ConflictSort.member, child: Text('Sort by member')),
          PopupMenuItem(
              child: StatefulBuilder(
                  builder: (context, popupSetState) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => popupSetState(
                          () => setState(() => _showIgnored = !_showIgnored)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Show ignored'),
                            Checkbox(
                                activeColor: _originTheme.primaryColor,
                                value: _showIgnored,
                                onChanged: (_) {
                                  popupSetState(() {
                                    setState(() {
                                      _showIgnored = !_showIgnored;
                                    });
                                  });
                                })
                          ]))))
        ],
        onSelected: (value) =>
            setState(() => _sortBy = value ?? ConflictSort.date),
      )
    ];
  }

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

    conflicts = _showIgnored
        ? conflicts
        : conflicts.where((element) => !element.gridData.ignore).toList();

    if (_sortBy == ConflictSort.date) {
      conflicts.sort((a, b) {
        int result = a.gridData.ignore == true && b.gridData.ignore == false
            ? 1
            : a.gridData.ignore == false && b.gridData.ignore == true
                ? -1
                : a.gridData.ignore == b.gridData.ignore ? 0 : null;

        if (result != 0)
          return result;
        else
          return a.conflictDates.length == 0 && b.conflictDates.length == 0
              ? 0
              : a.conflictDates.length == 0 && b.conflictDates.length > 0
                  ? -1
                  : a.conflictDates.length > 0 && b.conflictDates.length == 0
                      ? 1
                      : a.conflictDates.first.compareTo(b.conflictDates.first);
      });
    } else if (_sortBy == ConflictSort.member) {
      conflicts.sort((a, b) {
        int result = a.gridData.ignore == true && b.gridData.ignore == false
            ? 1
            : a.gridData.ignore == false && b.gridData.ignore == true
                ? -1
                : a.gridData.ignore == b.gridData.ignore ? 0 : null;

        if (result != 0)
          return result;
        else
          return a.gridData.dragData.member.docId
              .compareTo(b.gridData.dragData.member.docId);
      });
    }

    return conflicts;
  }

  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    _originTheme = Provider.of<OriginTheme>(context);

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
                    subtitle: 'Admin Panel'),
                actions: _generateActions()),
            drawer: HomeDrawer(DrawerEnum.group),
            floatingActionButton: groupStatus.me != null
                ? groupStatus.me.role == MemberRole.owner
                    ? GroupScreenOptionsOwner()
                    : groupStatus.me.role == MemberRole.admin
                        ? GroupScreenOptionsAdmin()
                        : null
                : null,
            body: StreamBuilder<List<Timetable>>(
                stream:
                    dbService.streamGroupTimetables(groupStatus.group.docId),
                builder: (context, snapshot) {
                  List<Conflict> conflicts = _generateConflicts(
                      members: groupStatus.members,
                      timetables: snapshot != null ? snapshot.data ?? [] : []);

                  return conflicts.length == 0
                      ? EmptyPlaceholder(
                          iconData: Icons.schedule,
                          text: 'No schedule conflicts')
                      : ListView.builder(
                          physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          itemCount: conflicts.length,
                          itemBuilder: (context, index) =>
                              ConflictListTile(conflict: conflicts[index]));
                }),
          );
  }
}
