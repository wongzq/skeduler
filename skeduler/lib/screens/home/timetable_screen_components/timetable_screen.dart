import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    TimetableAxes _axes = Provider.of<TimetableAxes>(context);

    return StreamBuilder(
        stream: dbService.getGroupMemberMyData(groupStatus.group.docId),
        builder: (context, snapshot) {
          Member me = snapshot != null ? snapshot.data : null;

          return FutureBuilder(
            future:
                dbService.getGroupTimetableIdForToday(groupStatus.group.docId),
            builder: (context, snapshotTtbId) {
              return StreamBuilder(
                stream: dbService.getGroupTimetableForToday(
                  groupStatus.group.docId,
                  snapshotTtbId.data,
                ),
                builder: (context, snapshotTtb) {
                  Timetable timetable =
                      snapshotTtb != null ? snapshotTtb.data : null;

                  if (timetable != null && ttbStatus.curr == null) {
                    ttbStatus.curr = timetable;
                  }

                  return groupStatus.group == null
                      ? Container()
                      : Scaffold(
                          appBar: AppBar(
                            title: groupStatus.group.name == null ||
                                    timetable == null ||
                                    !timetable.isValid()
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
                                      )
                                    ],
                                  ),
                            actions: <Widget>[
                              IconButton(
                                icon: PopupMenuButton(
                                  child: Icon(Icons.more_vert),
                                  itemBuilder: (BuildContext context) {
                                    List<PopupMenuEntry> timetableOptions = [];

                                    // Add timetables to options
                                    groupStatus.group.timetableMetadatas
                                        .forEach((timetableDocId) {
                                      timetableOptions.add(PopupMenuItem(
                                        value: timetableDocId.id,
                                        child: Text(timetableDocId.id),
                                      ));
                                    });

                                    // Add 'add timetable' button to options
                                    if (me.role == MemberRole.owner ||
                                        me.role == MemberRole.admin) {
                                      timetableOptions.add(PopupMenuItem(
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
                                                Icon(Icons.add),
                                                SizedBox(width: 10.0),
                                                Text('Add timetable'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ));
                                    } else if (me.role == MemberRole.member) {
                                      timetableOptions.add(PopupMenuItem(
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
                                                Icon(Icons.today),
                                                SizedBox(width: 10.0),
                                                Text('Today\'s timetable'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ));
                                    }
                                    return timetableOptions;
                                  },
                                  onSelected: (value) async {
                                    if (value == 0) {
                                      if (me.role == MemberRole.owner ||
                                          me.role == MemberRole.admin) {
                                        ttbStatus.edit = EditTimetable();
                                        _axes.clearAxes();
                                        Navigator.of(context).pushNamed(
                                          '/timetable/editor',
                                          arguments: RouteArgs(),
                                        );
                                      } else if (me.role == MemberRole.member) {
                                        setState(() {
                                          ttbStatus.curr = timetable;
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
                                        _axes.clearAxes();
                                        Navigator.of(context).pushNamed(
                                          '/timetable/editor',
                                          arguments: RouteArgs(),
                                        );
                                      } else if (me.role == MemberRole.member) {
                                        await dbService
                                            .getGroupTimetable(
                                                groupStatus.group.docId, value)
                                            .then((value) {
                                          ttbStatus.curr = value;
                                          setState(() {});
                                        });
                                      }
                                    }
                                  },
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          drawer: HomeDrawer(DrawerEnum.timetable),
                          body: me == null ||
                                  timetable == null ||
                                  !timetable.isValid()
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
