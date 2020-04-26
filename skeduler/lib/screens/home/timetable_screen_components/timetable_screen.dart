import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
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
    ValueNotifier<EditTimetableStatus> editTtb =
        Provider.of<ValueNotifier<EditTimetableStatus>>(context);

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
                                editTtb.value.perm = EditTimetable();
                                Navigator.of(context)
                                    .pushNamed('/timetable/editor');
                              } else {
                                editTtb.value.perm =
                                    EditTimetable.fromTimetable(
                                  await dbService.getGroupTimetable(
                                    group.value.docId,
                                    value,
                                  ),
                                );

                                Navigator.of(context)
                                    .pushNamed('/timetable/editor');
                              }
                            },
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    drawer: HomeDrawer(),
                    body: timetable == null || !timetable.isValid()
                        ? Container()
                        : TimetableDisplay(
                            editMode: false,
                            timetable: timetable,
                          ),
                  );
          },
        );
      },
    );
  }
}
