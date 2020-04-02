import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/drawer_enum.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/home/classes_screen_components/classes_screen.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/dashboard_screen.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen.dart';
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
  /// properties
  final AuthService _authService = AuthService();

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
        DashboardScreen(switchScreen: switchScreen);

    User user = Provider.of<User>(context);

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
          drawer: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Drawer(
              child: ListTileTheme(
                child: Column(
                  children: <Widget>[
                    /// User data display
                    UserAccountsDrawerHeader(
                      currentAccountPicture: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      accountName: Text(
                        user != null ? user.name : 'Name',
                        style: TextStyle(fontSize: 24.0),
                      ),
                      accountEmail: Text(
                        user != null ? user.email : 'email',
                        style: TextStyle(fontSize: 13.0),
                      ),
                    ),

                    /// Dashboard
                    Container(
                      color: selected.value == DrawerEnum.dashboard
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.dashboard),
                        title: Text(_screens[DrawerEnum.dashboard]['title']),
                        selected: selected.value == DrawerEnum.dashboard
                            ? true
                            : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnum.dashboard);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    Divider(thickness: 1.0),

                    /// Group
                    Container(
                      color: selected.value == DrawerEnum.group
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(FontAwesomeIcons.users),
                        title: Text(_screens[DrawerEnum.group]['title']),
                        selected:
                            selected.value == DrawerEnum.group ? true : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnum.group);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// Timetable
                    Container(
                      color: selected.value == DrawerEnum.timetable
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.table_chart),
                        title: Text(_screens[DrawerEnum.timetable]['title']),
                        selected: selected.value == DrawerEnum.timetable
                            ? true
                            : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnum.timetable);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// Classes
                    Container(
                      color: selected.value == DrawerEnum.classes
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.school),
                        title: Text(_screens[DrawerEnum.classes]['title']),
                        selected:
                            selected.value == DrawerEnum.classes ? true : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnum.classes);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// People
                    Container(
                      color: selected.value == DrawerEnum.people
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.people),
                        title: Text(_screens[DrawerEnum.people]['title']),
                        selected:
                            selected.value == DrawerEnum.people ? true : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnum.people);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// Profile
                    Container(
                      color: selected.value == DrawerEnum.profile
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.person),
                        title: Text(_screens[DrawerEnum.profile]['title']),
                        selected:
                            selected.value == DrawerEnum.profile ? true : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnum.profile);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    Divider(thickness: 1.0),

                    /// Settings
                    Container(
                      color: selected.value == DrawerEnum.settings
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.settings),
                        title: Text(_screens[DrawerEnum.settings]['title']),
                        selected: selected.value == DrawerEnum.settings
                            ? true
                            : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnum.settings);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// Logout
                    Container(
                      color: selected.value == DrawerEnum.logout
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.exit_to_app),
                        title: Text(_screens[DrawerEnum.logout]['title']),
                        selected:
                            selected.value == DrawerEnum.logout ? true : false,
                        onTap: () {
                          //setState(() => selected.value = DrawerEnum.logout);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text('Do you want to logout?'),
                                actions: <Widget>[
                                  /// CANCEL button
                                  FlatButton(
                                    child: Text('CANCEL'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),

                                  /// OK button
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      /// pop AlertDialog
                                      Navigator.of(context).pop();

                                      /// pop Drawer
                                      Navigator.of(context).pop();

                                      _authService.logOut();

                                      /// ThemeProvider.controllerOf(context).setTheme('default');
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Scaffold - body
          body: () {
            return _screens[selected.value]['screen'];
          }(),
        );
      }),
    );
  }
}
