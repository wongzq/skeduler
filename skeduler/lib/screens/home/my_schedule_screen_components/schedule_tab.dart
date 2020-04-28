import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/schedule_view.dart';
import 'package:skeduler/shared/functions.dart';

class ScheduleTab extends StatefulWidget {
  @override
  _ScheduleTabState createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Container()
        : Stack(
            children: <Widget>[
              ScheduleView(),
              Positioned(
                bottom: 20.0,
                right: 20.0,
                child: FloatingActionButton(
                  heroTag: 'Schedule Editor',
                  foregroundColor: getFABIconForegroundColor(context),
                  backgroundColor: getFABIconBackgroundColor(context),
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).pushNamed(
                        '/mySchedule/scheduleEditor',
                        arguments: RouteArgs(),
                      );
                    });
                  },
                  child: Icon(
                    Icons.edit,
                  ),
                ),
              )
            ],
          );
  }
}
