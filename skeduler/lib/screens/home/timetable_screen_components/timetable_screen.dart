import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_display.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/ui_settings.dart';

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

    return StreamBuilder(
        stream: dbService.streamGroupMemberMe(groupStatus.group.docId),
        builder: (context, snapshot) {
          Member me = snapshot != null ? snapshot.data : null;

          return FutureBuilder(
            future:
                dbService.getGroupTimetableIdForToday(groupStatus.group.docId),
            builder: (context, snapshotTtbId) {
              return StreamBuilder(
                stream: dbService.streamGroupTimetableForToday(
                  groupStatus.group.docId,
                  snapshotTtbId.data,
                ),
                builder: (context, snapshotTtb) {
                  Timetable timetable =
                      snapshotTtb != null ? snapshotTtb.data : null;

                  if (_viewTodayTtb && timetable != null) {
                    if (ttbStatus.curr == null) {
                      ttbStatus.curr = timetable;
                    } else if (ttbStatus.curr.docId == timetable.docId) {
                      ttbStatus.curr = timetable;
                    } else {
                      ttbStatus.curr = null;
                      ttbStatus.curr = timetable;
                    }
                  }

                  return groupStatus.group == null
                      ? Container()
                      : Scaffold(
                          appBar: AppBar(
                            title: groupStatus.group.name == null ||
                                    timetable == null ||
                                    !timetable.isValid
                                ? Text(
                                    'Timetable',
                                    style: textStyleAppBarTitle,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        groupStatus.group.name,
                                        style: textStyleAppBarTitle,
                                      ),
                                      Text(
                                        'Timetable: ${ttbStatus.curr.docId}',
                                        style: textStyleBody,
                                      ),
                                    ],
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
                                          value: timetableMetadata.id,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(timetableMetadata.id),
                                              Text(
                                                DateFormat('dd MMM').format(
                                                        timetableMetadata
                                                            .startDate
                                                            .toDate()) +
                                                    ' - ' +
                                                    DateFormat('dd MMM').format(
                                                        timetableMetadata
                                                            .endDate
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
                                    if (me.role == MemberRole.owner ||
                                        me.role == MemberRole.admin) {
                                      popupOptions.add(PopupMenuItem(
                                        value: 0,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Visibility(
                                              visible: groupStatus
                                                  .group
                                                  .timetableMetadatas
                                                  .isNotEmpty,
                                              child: Divider(thickness: 1.0),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.add,
                                                  color: Theme.of(context)
                                                              .brightness ==
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
                                    } else if (me.role == MemberRole.member) {
                                      popupOptions.add(PopupMenuItem(
                                        value: 0,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Visibility(
                                              visible: groupStatus
                                                  .group
                                                  .timetableMetadatas
                                                  .isNotEmpty,
                                              child: Divider(thickness: 1.0),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.today,
                                                  color: Theme.of(context)
                                                              .brightness ==
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
                                      if (me.role == MemberRole.owner ||
                                          me.role == MemberRole.admin) {
                                        ttbStatus.temp = EditTimetable();
                                        Navigator.of(context).pushNamed(
                                          '/timetable/newTimetable',
                                          arguments: RouteArgs(),
                                        );
                                      } else if (me.role == MemberRole.member) {
                                        setState(() {
                                          _viewTodayTtb = true;
                                          ttbStatus.curr = null;
                                        });
                                      }
                                    } else if (value is String) {
                                      if (me.role == MemberRole.owner ||
                                          me.role == MemberRole.admin) {
                                        ttbStatus.edit =
                                            EditTimetable.fromTimetable(
                                          await dbService.getGroupTimetable(
                                            groupStatus.group.docId,
                                            value,
                                          ),
                                        );
                                        Navigator.of(context).pushNamed(
                                          '/timetable/editor',
                                          arguments: RouteArgs(),
                                        );
                                      } else if (me.role == MemberRole.member) {
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
                          body: me == null ||
                                  timetable == null ||
                                  !timetable.isValid
                              ? Container()
                              : TimetableDisplay(
                                  editMode: TimetableEditMode(editMode: false),
                                ),
                        );
                },
              );
            },
          );
        });
  }
}
