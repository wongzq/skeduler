import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/drawer_enum.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/home/classes_screen_components/classes_screen.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/dashboard_screen.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
import 'package:skeduler/screens/home/people_screen_components/people_screen.dart';
import 'package:skeduler/screens/home/profile_screen_components/profile_screen.dart';
import 'package:skeduler/screens/home/settings_screen_components/settings_screen.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_screen.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/shared/ui_settings.dart';

import 'dashboard_screen_components/dashboard_screen.dart';

class Home extends StatefulWidget {
  static _HomeState of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeState>();

  /// methods
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  /// Map of screens
  ValueNotifier<DrawerEnum> _selected =
      ValueNotifier<DrawerEnum>(DrawerEnum.dashboard);
  Map<DrawerEnum, Map<String, Object>> _screens;

  DashboardScreen _dashboardScreen = DashboardScreen();
  GroupScreen _groupScreen = GroupScreen();
  TimetableScreen _timetableScreen = TimetableScreen();
  ClassesScreen _classesScreen = ClassesScreen();
  PeopleScreen _peopleScreen = PeopleScreen();
  ProfileScreen _profileScreen = ProfileScreen();
  SettingsScreen _settingsScreen = SettingsScreen();

  ValueNotifier<String> _groupDocId = ValueNotifier(null);

  void switchScreen() => setState(() {});

  @override
  void initState() {
    _screens = {
      DrawerEnum.dashboard: {'title': 'Dashboard', 'screen': _dashboardScreen},
      DrawerEnum.group: {'title': 'Group', 'screen': _groupScreen},
      DrawerEnum.timetable: {'title': 'Timetable', 'screen': _timetableScreen},
      DrawerEnum.classes: {'title': 'Classes', 'screen': _classesScreen},
      DrawerEnum.people: {'title': 'People', 'screen': _peopleScreen},
      DrawerEnum.profile: {'title': 'Profile', 'screen': _profileScreen},
      DrawerEnum.settings: {'title': 'Settings', 'screen': _settingsScreen},
      DrawerEnum.logout: {'title': 'Logout', 'screen': null},
    };
    super.initState();
  }

  /// methods
  @override
  Widget build(BuildContext context) {
    _screens[DrawerEnum.dashboard]['screen'] =
        DashboardScreen();

    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ValueNotifier<String>>.value(
          value: _groupDocId,
        ),
        ChangeNotifierProvider<ValueNotifier<DrawerEnum>>.value(
          value: _selected,
        ),
      ],
      child: Consumer<ValueNotifier<DrawerEnum>>(builder: (BuildContext context,
          ValueNotifier<DrawerEnum> selected, Widget widget) {
        return Scaffold(
          /// Scaffold - appBar
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              _screens[selected.value]['title'],
              style: textStyleAppBarTitle,
            ),
          ),

          /// Scaffold - drawer
          drawer: HomeDrawer(),
          /// Scaffold - body
          body: () {
            return _screens[selected.value]['screen'];
          }(),
        );
      }),
    );
  }
}
