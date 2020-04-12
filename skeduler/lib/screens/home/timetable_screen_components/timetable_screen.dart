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

    return StreamBuilder<Object>(
      stream: dbService.getGroup(groupDocId.value),
      builder: (context, snapshot) {
        Group group = snapshot != null ? snapshot.data : null;

        return StreamBuilder<Object>(
            stream: dbService.getGroupTimetables(groupDocId.value),
            builder: (context, snapshot) {
              List<Timetable> timetables =
                  snapshot != null ? snapshot.data : null;

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
                            icon: Icon(Icons.settings),
                            onPressed: () => Navigator.of(context)
                                .pushNamed('/timetableSettings'),
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
                                foregroundColor:
                                    getFABIconForegroundColor(context),
                                backgroundColor:
                                    getFABIconBackgroundColor(context),
                                child: Icon(Icons.save),
                                onPressed: () {
                                  // dbService.updateGroupTimetable(
                                  //     groupDocId.value, timetable);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
            });
      },
    );
  }
}
