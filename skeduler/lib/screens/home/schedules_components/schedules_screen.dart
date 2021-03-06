import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/navigation/home_drawer.dart';
import 'package:skeduler/screens/home/schedules_components/availability/availability_fab.dart';
import 'package:skeduler/screens/home/schedules_components/availability/availability_view.dart';
import 'package:skeduler/screens/home/schedules_components/schedule/schedule_view.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class MyScheduleScreen extends StatefulWidget {
  @override
  _MyScheduleScreenState createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen>
    with TickerProviderStateMixin {
  // properties
  int _tabs = 2;
  TabController _tabController;

  // methods
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
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Stack(children: <Widget>[
            Scaffold(
                appBar: AppBar(
                    title:
                        AppBarTitle(title: 'Group', subtitle: 'My schedule')),
                drawer: HomeDrawer(DrawerEnum.schedules)),
            Loading()
          ])
        : Scaffold(
            appBar: AppBar(
                elevation: 0.0,
                title: AppBarTitle(
                    title: groupStatus.group.name,
                    alternateTitle: 'Group',
                    subtitle: groupStatus.member.docId == groupStatus.me.docId
                        ? 'My schedule'
                        : groupStatus.member.name + '\'s schedule'),
                bottom: TabBar(
                    onTap: (tab) => setState(() {}),
                    controller: _tabController,
                    indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                    tabs: <Widget>[
                      Tab(
                          text: null,
                          child: Text('Schedule',
                              style: TextStyle(
                                  color: _tabController.index == 0
                                      ? Theme.of(context)
                                          .primaryTextTheme
                                          .bodyText1
                                          .color
                                      : Theme.of(context)
                                          .primaryTextTheme
                                          .bodyText1
                                          .color
                                          .withOpacity(0.3),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400))),
                      Tab(
                          text: null,
                          child: Text('Availability',
                              style: TextStyle(
                                color: _tabController.index == 1
                                    ? Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText1
                                        .color
                                    : Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText1
                                        .color
                                        .withOpacity(0.3),
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              )))
                    ])),
            drawer: HomeDrawer(groupStatus.me.docId == groupStatus.member.docId
                ? DrawerEnum.schedules
                : DrawerEnum.members),
            body: TabBarView(controller: _tabController, children: <Widget>[
              ScheduleView(),
              Stack(children: <Widget>[AvailabilityView(), AvailabilityFAB()])
            ]));
  }
}
