import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/schedule_tab.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/ui_settings.dart';

class MyScheduleScreen extends StatefulWidget {
  @override
  _MyScheduleScreenState createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen>
    with TickerProviderStateMixin {
  /// properties

  int _tabs = 2;
  TabController _tabController;

  /// methods
  void _switchTab() {
    setState(() {});
  }

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: _tabs);
    _tabController.addListener(_switchTab);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Group> group = Provider.of<ValueNotifier<Group>>(context);

    return group.value == null
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: group.value.name == null
                  ? Text(
                      'My Schedule',
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
                          'My Schedule',
                          style: textStyleBody,
                        )
                      ],
                    ),
              bottom: TabBar(
                onTap: (tab) {
                  setState(() {});
                },
                controller: _tabController,
                indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                tabs: <Widget>[
                  Tab(
                    text: null,
                    child: Text(
                      'Schedule',
                      style: TextStyle(
                        color: _tabController.index == 0
                            ? Theme.of(context).primaryTextTheme.title.color
                            : Theme.of(context)
                                .primaryTextTheme
                                .title
                                .color
                                .withOpacity(0.3),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Tab(
                    text: null,
                    child: Text(
                      'Calendar',
                      style: TextStyle(
                        color: _tabController.index == 1
                            ? Theme.of(context).primaryTextTheme.title.color
                            : Theme.of(context)
                                .primaryTextTheme
                                .title
                                .color
                                .withOpacity(0.3),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
            drawer: HomeDrawer(),
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                ScheduleTab(),
                Container(),
              ],
            ),
          );
  }
}
