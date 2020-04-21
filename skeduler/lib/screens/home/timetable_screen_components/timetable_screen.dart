import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_display.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);
    ValueNotifier<EditTimetable> editTtb =
        Provider.of<ValueNotifier<EditTimetable>>(context);

    return StreamBuilder<Object>(
        stream: dbService.getGroup(groupDocId.value),
        builder: (context, snapshot) {
          Group group = snapshot != null ? snapshot.data : null;

          return group == null
              ? Container()
              : Scaffold(
                  appBar: AppBar(
                    title: group.name == null
                        ? Text(
                            'Timetable',
                            style: textStyleAppBarTitle,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                group.name,
                                style: textStyleAppBarTitle,
                              ),
                              Text(
                                'Timetable',
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
                            group.timetables.forEach((timetableDocId) {
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
                                    visible: group.timetables.isNotEmpty,
                                    // visible: true,
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
                              editTtb.value = EditTimetable();
                              Navigator.of(context)
                                  .pushNamed('/timetableEditor');
                            } else {
                              editTtb.value = EditTimetable.fromTimetable(
                                await dbService.getGroupTimetable(
                                  groupDocId.value,
                                  value,
                                ),
                              );

                              Navigator.of(context)
                                  .pushNamed('/timetableEditor');
                            }
                          },
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  drawer: HomeDrawer(),
                  floatingActionButton: FloatingActionButton(
                    foregroundColor: getFABIconForegroundColor(context),
                    backgroundColor: getFABIconBackgroundColor(context),
                    child: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/timetableEditor');
                    },
                  ),
                  body: TimetableDisplay(),
                );
        });
  }
}
