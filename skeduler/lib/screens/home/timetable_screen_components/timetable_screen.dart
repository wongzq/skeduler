import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
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
    ValueNotifier<TempTimetable> tempTTB =
        Provider.of<ValueNotifier<TempTimetable>>(context);

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
                                value: timetableDocId,
                                child: Text(timetableDocId),
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
                              Navigator.of(context)
                                  .pushNamed('/timetableEditor');
                            } else {
                              tempTTB.value = TempTimetable(
                                  timetable: await dbService.getGroupTimetable(
                                      groupDocId.value, value));

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
                  body: Stack(
                    children: <Widget>[
                      Container(),
                      Visibility(
                        visible: true,
                        child: Positioned(
                          right: 20.0,
                          bottom: 20.0,
                          child: FloatingActionButton(
                            foregroundColor: getFABIconForegroundColor(context),
                            backgroundColor: getFABIconBackgroundColor(context),
                            child: Icon(Icons.edit),
                            onPressed: () {
                              TempTimetable tempTimetable = TempTimetable();
                              Navigator.of(context).pushNamed(
                                  '/timetableEditor',
                                  arguments: tempTimetable);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        });
  }
}
