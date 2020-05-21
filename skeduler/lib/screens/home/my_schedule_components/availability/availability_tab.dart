import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/availability_view.dart';
import 'package:skeduler/shared/functions.dart';

class AvailabilityTab extends StatefulWidget {
  @override
  _AvailabilityTabState createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<AvailabilityTab> {
  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Container()
        : Stack(
            children: <Widget>[
              AvailabilityView(),
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
              ),
            ],
          );
  }
}
