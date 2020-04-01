import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/drawer_enum.dart';
import 'package:skeduler/models/group.dart';
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

  // DrawerEnum _selected = DrawerEnum.dashboard;
  DrawerEnum _selected = DrawerEnum(DrawerEnums.dashboard);
  
  void switchScreen({Group group}) {
    setState(() {
      if (group != null) {
        _screens[DrawerEnums.group]['screen'] =
            GroupScreen(group: group);
      }
    });
  }

  /// Map of screens
  static DashboardScreen _dashboardScreen = DashboardScreen();
  static GroupScreen _groupScreen = GroupScreen();
  static TimetableScreen _timetableScreen = TimetableScreen();
  static ClassesScreen _classesScreen = ClassesScreen();
  static PeopleScreen _peopleScreen = PeopleScreen();
  static ProfileScreen _profileScreen = ProfileScreen();
  static SettingsScreen _settingsScreen = SettingsScreen();

  Map<DrawerEnums, Map<String, Object>> _screens = {
    DrawerEnums.dashboard: {'title': 'Dashboard', 'screen': _dashboardScreen},
    DrawerEnums.group: {'title': 'Group', 'screen': _groupScreen},
    DrawerEnums.timetable: {'title': 'Timetable', 'screen': _timetableScreen},
    DrawerEnums.classes: {'title': 'Classes', 'screen': _classesScreen},
    DrawerEnums.people: {'title': 'People', 'screen': _peopleScreen},
    DrawerEnums.profile: {'title': 'Profile', 'screen': _profileScreen},
    DrawerEnums.settings: {'title': 'Settings', 'screen': _settingsScreen},
    DrawerEnums.logout: {'title': 'Logout', 'screen': null},
  };

  /// methods
  @override
  Widget build(BuildContext context) {
    _screens[DrawerEnums.dashboard]['screen'] =
        DashboardScreen(callback: switchScreen);

    User user = Provider.of<User>(context);

    return ChangeNotifierProvider<DrawerEnum>.value(
      value: _selected,
      child: Consumer<DrawerEnum>(
          builder: (BuildContext context, DrawerEnum selected, Widget widget) {
        return Scaffold(
          /// Scaffold - appBar
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              _screens[selected.value]['title'],
              style: appBarTitleTextStyle,
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
                      color: selected.value == DrawerEnums.dashboard
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.dashboard),
                        title: Text(_screens[DrawerEnums.dashboard]['title']),
                        selected: selected.value == DrawerEnums.dashboard
                            ? true
                            : false,
                        onTap: () {
                          setState(
                              () => selected.value = DrawerEnums.dashboard);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    Divider(thickness: 1.0),

                    /// Group
                    Container(
                      color: selected.value == DrawerEnums.group
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(FontAwesomeIcons.users),
                        title: Text(_screens[DrawerEnums.group]['title']),
                        selected:
                            selected.value == DrawerEnums.group ? true : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnums.group);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// Timetable
                    Container(
                      color: selected.value == DrawerEnums.timetable
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.table_chart),
                        title: Text(_screens[DrawerEnums.timetable]['title']),
                        selected: selected.value == DrawerEnums.timetable
                            ? true
                            : false,
                        onTap: () {
                          setState(
                              () => selected.value = DrawerEnums.timetable);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// Classes
                    Container(
                      color: selected.value == DrawerEnums.classes
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.school),
                        title: Text(_screens[DrawerEnums.classes]['title']),
                        selected: selected.value == DrawerEnums.classes
                            ? true
                            : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnums.classes);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// People
                    Container(
                      color: selected.value == DrawerEnums.people
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.people),
                        title: Text(_screens[DrawerEnums.people]['title']),
                        selected:
                            selected.value == DrawerEnums.people ? true : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnums.people);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// Profile
                    Container(
                      color: selected.value == DrawerEnums.profile
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.person),
                        title: Text(_screens[DrawerEnums.profile]['title']),
                        selected: selected.value == DrawerEnums.profile
                            ? true
                            : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnums.profile);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    Divider(thickness: 1.0),

                    /// Settings
                    Container(
                      color: selected.value == DrawerEnums.settings
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.settings),
                        title: Text(_screens[DrawerEnums.settings]['title']),
                        selected: selected.value == DrawerEnums.settings
                            ? true
                            : false,
                        onTap: () {
                          setState(() => selected.value = DrawerEnums.settings);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    /// Logout
                    Container(
                      color: selected.value == DrawerEnums.logout
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.exit_to_app),
                        title: Text(_screens[DrawerEnums.logout]['title']),
                        selected:
                            selected.value == DrawerEnums.logout ? true : false,
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
