import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_display.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  bool _viewTodayTtb;

  @override
  void initState() {
    _viewTodayTtb = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);

    return FutureBuilder(
      future: dbService.getGroupTimetableIdForToday(groupStatus.group.docId),
      builder: (context, snapshotTtbId) {
        return StreamBuilder(
          stream: dbService.streamGroupTimetableForToday(
            groupStatus.group.docId,
            snapshotTtbId.data,
          ),
          builder: (context, snapshotTtb) {
            Timetable timetable = snapshotTtb != null ? snapshotTtb.data : null;
            bool isPlaceholder;

            if (timetable != null && timetable.isValid) {
              isPlaceholder = false;

              if (_viewTodayTtb) {
                if (ttbStatus.curr == null) {
                  ttbStatus.curr = timetable;
                } else if (ttbStatus.curr.docId == timetable.docId) {
                  ttbStatus.curr = timetable;
                } else {
                  ttbStatus.curr = null;
                  ttbStatus.curr = timetable;
                }
              }
            } else {
              isPlaceholder = true;
              ttbStatus.curr = null;
              ttbStatus.curr = Timetable(
                docId: null,
                gridAxisOfDay: GridAxis.x,
                gridAxisOfTime: GridAxis.y,
                gridAxisOfCustom: GridAxis.z,
                axisDay: [
                  Weekday.mon,
                  Weekday.tue,
                  Weekday.wed,
                  Weekday.thu,
                  Weekday.fri,
                ],
                axisTime: [
                  Time(
                    DateTime(DateTime.now().year, 1, 1, DateTime.now().hour),
                    DateTime(DateTime.now().year, 1, 1,
                        DateTime.now().add(Duration(hours: 1)).hour),
                  ),
                  Time(
                    DateTime(DateTime.now().year, 1, 1,
                        DateTime.now().add(Duration(hours: 2)).hour),
                    DateTime(DateTime.now().year, 1, 1,
                        DateTime.now().add(Duration(hours: 3)).hour),
                  ),
                ],
                axisCustom: ['Example\nA', 'Example\nB'],
                gridDataList: TimetableGridDataList(),
              );
            }

            return groupStatus.group == null
                ? Scaffold()
                : Scaffold(
                    appBar: AppBar(
                      title: AppBarTitle(
                        title: groupStatus.group.name == null
                            ? null
                            : groupStatus.group.name,
                        alternateTitle: 'Timetable',
                        subtitle: groupStatus.group.name == null ||
                                timetable == null ||
                                !timetable.isValid ||
                                ttbStatus.curr == null
                            ? 'No timetable for today'
                            : 'Timetable: ${ttbStatus.curr.docId}',
                      ),
                      actions: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: PopupMenuButton(
                            child: Icon(Icons.more_vert),
                            itemBuilder: (BuildContext context) {
                              List<PopupMenuEntry> popupOptions = [];

                              // Add timetables to options
                              groupStatus.group.timetableMetadatas
                                  .forEach((timetableMetadata) {
                                popupOptions.add(
                                  PopupMenuItem(
                                    value: timetableMetadata.docId,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(timetableMetadata.docId),
                                        Text(
                                          DateFormat('dd MMM').format(
                                                  timetableMetadata.startDate
                                                      .toDate()) +
                                              ' - ' +
                                              DateFormat('dd MMM').format(
                                                  timetableMetadata.endDate
                                                      .toDate()),
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });

                              // Add 'add timetable' button to options
                              if (groupStatus.me.role == MemberRole.owner ||
                                  groupStatus.me.role == MemberRole.admin) {
                                popupOptions.add(PopupMenuItem(
                                  value: 0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Visibility(
                                        visible: groupStatus.group
                                            .timetableMetadatas.isNotEmpty,
                                        child: Divider(thickness: 1.0),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.add,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                          SizedBox(width: 10.0),
                                          Text('Add timetable'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ));
                              } else if (groupStatus.me.role ==
                                  MemberRole.member) {
                                popupOptions.add(PopupMenuItem(
                                  value: 0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Visibility(
                                        visible: groupStatus.group
                                            .timetableMetadatas.isNotEmpty,
                                        child: Divider(thickness: 1.0),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.today,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                          SizedBox(width: 10.0),
                                          Text('Today\'s timetable'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ));
                              }
                              return popupOptions;
                            },
                            onSelected: (value) async {
                              if (value == 0) {
                                if (groupStatus.me.role == MemberRole.owner ||
                                    groupStatus.me.role == MemberRole.admin) {
                                  ttbStatus.temp = EditTimetable(
                                    axisDay: List.generate(
                                        5, (index) => Weekday.values[index]),
                                    axisTime: [
                                      Time(
                                        DateTime(DateTime.now().year).add(
                                          Duration(
                                              hours: DateTime.now().hour + 0),
                                        ),
                                        DateTime(DateTime.now().year).add(
                                          Duration(
                                              hours: DateTime.now().hour + 1),
                                        ),
                                      ),
                                      Time(
                                        DateTime(DateTime.now().year).add(
                                          Duration(
                                              hours: DateTime.now().hour + 2),
                                        ),
                                        DateTime(DateTime.now().year).add(
                                          Duration(
                                              hours: DateTime.now().hour + 3),
                                        ),
                                      ),
                                    ],
                                    axisCustom: ['A', 'B'],
                                  );
                                  Navigator.of(context).pushNamed(
                                    '/timetable/newTimetable',
                                    arguments: RouteArgs(),
                                  );
                                } else if (groupStatus.me.role ==
                                    MemberRole.member) {
                                  setState(() {
                                    _viewTodayTtb = true;
                                    ttbStatus.curr = null;
                                  });
                                }
                              } else if (value is String) {
                                if (groupStatus.me.role == MemberRole.owner ||
                                    groupStatus.me.role == MemberRole.admin) {
                                  ttbStatus.edit = EditTimetable.fromTimetable(
                                    await dbService.getGroupTimetable(
                                      groupStatus.group.docId,
                                      value,
                                    ),
                                  );
                                  Navigator.of(context).pushNamed(
                                    '/timetable/editor',
                                    arguments: RouteArgs(),
                                  );
                                } else if (groupStatus.me.role ==
                                    MemberRole.member) {
                                  await dbService
                                      .getGroupTimetable(
                                          groupStatus.group.docId, value)
                                      .then((value) {
                                    setState(() {
                                      _viewTodayTtb = false;
                                      ttbStatus.curr = null;
                                      ttbStatus.curr = value;
                                    });
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    drawer: HomeDrawer(DrawerEnum.timetable),
                    body: groupStatus.me == null
                        ? Container()
                        : TimetableDisplay(
                            editMode: TimetableEditMode(
                              isPlaceholder: isPlaceholder,
                              editMode: false,
                            ),
                          ),
                  );
          },
        );
      },
    );
  }
}
