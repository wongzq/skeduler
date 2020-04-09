import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
import 'package:skeduler/screens/home/profile_screen_components/schedule_tab.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

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
  void _switchTab() {}

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
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return StreamBuilder<Object>(
        stream: dbService.getGroup(groupDocId.value),
        builder: (context, snapshot) {
          Group group = snapshot != null ? snapshot.data : null;

          Color backgroundColor;
          IconThemeData iconTheme;
          TextTheme textTheme;

          if (group != null) {
            bool lightShade = group.colorShade.shade == Shade.primaryColorLight;

            backgroundColor = getOriginThemeColorShade(group.colorShade);
            iconTheme = lightShade
                ? ThemeProvider.themeOf(context)
                    .data
                    .iconTheme
                    .copyWith(color: Colors.black)
                : getOriginThemeData(group.colorShade.themeId).primaryIconTheme;
            textTheme = lightShade
                ? ThemeProvider.themeOf(context)
                    .data
                    .textTheme
                    .copyWith(title: TextStyle(color: Colors.black))
                : getOriginThemeData(group.colorShade.themeId).primaryTextTheme;
          }

          return group == null
              ? Loading()
              : Scaffold(
                  appBar: AppBar(
                    backgroundColor: backgroundColor,
                    iconTheme: iconTheme,
                    textTheme: textTheme,
                    elevation: 0.0,
                    title: group.name == null
                        ? Text(
                            'My Schedule',
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
                                  ? textTheme.title.color
                                  : textTheme.title.color.withOpacity(0.3),
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
                                  ? textTheme.title.color
                                  : textTheme.title.color.withOpacity(0.3),
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
                      // ScheduleEditor(),
                      ScheduleTab(),
                      Container(),
                    ],
                  ),
                );
        });
  }
}
