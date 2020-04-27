import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
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
    ValueNotifier<Group> group = Provider.of<ValueNotifier<Group>>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    TimetableAxes _axes = Provider.of<TimetableAxes>(context);

    return FutureBuilder(
      future: dbService.getGroupTimetableIdForToday(group.value.docId),
      builder: (context, snapshotTtbId) {
        return StreamBuilder(
          stream: dbService.getGroupTimetableForToday(
            group.value.docId,
            snapshotTtbId.data,
          ),
          builder: (context, snapshotTtb) {
            Timetable timetable = snapshotTtb != null ? snapshotTtb.data : null;

            if (timetable != null) {
              // ttbStatus.perm = EditTimetable.fromTimetable(timetable);
              ttbStatus.curr = timetable;
            }

            return group.value == null
                ? Container()
                : Scaffold(
                    appBar: AppBar(
                      title: group.value.name == null ||
                              timetable == null ||
                              !timetable.isValid()
                          ? Text(
                              'Timetable',
                              style: textStyleAppBarTitle,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  group.value.name,
                                  style: textStyleAppBarTitle,
                                ),
                                Text(
                                  'Timetable: ${timetable.docId}',
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

                              /// Add timetables to options
                              group.value.timetables.forEach((timetableDocId) {
                                timetableOptions.add(PopupMenuItem(
                                  value: timetableDocId.id,
                                  child: Text(timetableDocId.id),
                                ));
                              });

                              /// Add 'add timetable' button to options
                              timetableOptions.add(PopupMenuItem(
                                value: 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Visibility(
                                      visible:
                                          group.value.timetables.isNotEmpty,
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

                              return timetableOptions;
                            },
                            onSelected: (value) async {
                              if (value == 0) {
                                ttbStatus.perm = EditTimetable();
                                _axes.clearAxes();
                                Navigator.of(context).pushNamed(
                                  '/timetable/editor',
                                  arguments: RouteArgs(),
                                );
                              } else {
                                ttbStatus.perm = EditTimetable.fromTimetable(
                                  await dbService.getGroupTimetable(
                                    group.value.docId,
                                    value,
                                  ),
                                );
                                _axes.clearAxes();
                                Navigator.of(context).pushNamed(
                                  '/timetable/editor',
                                  arguments: RouteArgs(),
                                );
                              }
                            },
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    drawer: HomeDrawer(DrawerEnum.timetable),
                    body: timetable == null || !timetable.isValid()
                        ? Container()
                        : TimetableDisplay(
                            editMode: false,
                          ),
                  );
          },
        );
      },
    );
  }
}
