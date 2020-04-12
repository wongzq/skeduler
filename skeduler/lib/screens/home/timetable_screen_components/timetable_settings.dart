import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/screens/home/timetable_screen_components/axis_day.dart';
import 'package:skeduler/screens/home/timetable_screen_components/axis_time.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableSettings extends StatelessWidget {
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
              ? Loading()
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
                  ),
                  body: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ListView(
                      physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      children: <Widget>[
                        AxisDay(),
                        AxisTime(),
                        // AxisCustom(),
                      ],
                    ),
                  ),
                );
        });
  }
}
