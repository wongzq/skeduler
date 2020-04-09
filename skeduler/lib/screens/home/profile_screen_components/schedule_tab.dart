import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/screens/home/profile_screen_components/schedule_view.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';

class ScheduleTab extends StatefulWidget {
  @override
  _ScheduleTabState createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return StreamBuilder<Object>(
        stream: dbService.getGroup(groupDocId.value),
        builder: (context, snapshot) {
          Group group = snapshot != null ? snapshot.data : null;

          return group == null
              ? Container()
              : Stack(
                  children: <Widget>[
                    ScheduleView(),
                    Positioned(
                      bottom: 20.0,
                      right: 20.0,
                      child: FloatingActionButton(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : getOriginThemeData(group.colorShade.themeId)
                                    .primaryColorDark,
                        onPressed: () {
                          setState(() {
                            Navigator.of(context)
                                .pushNamed('/mySchedule/scheduleEditor');
                          });
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                );
        });
  }
}
