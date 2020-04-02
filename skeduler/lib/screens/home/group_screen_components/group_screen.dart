import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen_options.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/ui_settings.dart';

class GroupScreen extends StatefulWidget {
  final void Function({String groupName}) refresh;

  const GroupScreen({this.refresh});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  String _groupName;

  @override
  void initState() {
    SchedulerBinding.instance
        .addPostFrameCallback((_) => widget.refresh(groupName: _groupName));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return groupDocId.value == null
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                'Group',
                style: textStyleAppBarTitle,
              ),
            ),
            drawer: HomeDrawer(),
          )
        : StreamBuilder(
            stream: dbService.getGroup(groupDocId.value),
            builder: (context, snapshot) {
              Group group = snapshot != null ? snapshot.data : null;

              return snapshot.data == null
                  ? Loading()
                  : Scaffold(
                      appBar: AppBar(
                        backgroundColor: Theme.of(context).primaryColor,
                        title: group.name == null
                            ? Text(
                                'Group',
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
                                    'Group',
                                    style: textStyleBodyLight,
                                  )
                                ],
                              ),
                      ),
                      drawer: HomeDrawer(),
                      body: Stack(
                        children: <Widget>[
                          // Text: Group name
                          Container(
                            padding: EdgeInsets.all(20.0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              group.description,
                              style: textStyleBody,
                            ),
                          ),

                          // SpeedDial: Options
                          GroupScreenOptions(),
                        ],
                      ),
                    );
            });
  }
}
