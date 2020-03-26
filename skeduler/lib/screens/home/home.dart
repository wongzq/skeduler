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
import 'package:skeduler/services/database_service.dart';

class Home extends StatefulWidget {
  static _HomeState of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeState>();

  // methods
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // properties
  final AuthService _authService = AuthService();

  DrawerEnum _selected = DrawerEnum.settings;

  // Map of screens
  Map<DrawerEnum, Map<String, Object>> _screens = {
    DrawerEnum.dashboard: {'title': 'Dashboard', 'screen': DashboardScreen()},
    DrawerEnum.group: {'title': 'Group', 'screen': GroupScreen()},
    DrawerEnum.timetable: {'title': 'Timetable', 'screen': TimetableScreen()},
    DrawerEnum.classes: {'title': 'Classes', 'screen': ClassesScreen()},
    DrawerEnum.people: {'title': 'People', 'screen': PeopleScreen()},
    DrawerEnum.profile: {'title': 'Profile', 'screen': ProfileScreen()},
    DrawerEnum.settings: {'title': 'Settings', 'screen': SettingsScreen()},
    DrawerEnum.logout: {'title': 'Logout', 'screen': null},
  };

  // methods
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    DatabaseService _databaseService = DatabaseService(uid: user.uid);

    return StreamBuilder<UserData>(
      stream: _databaseService.userData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        UserData userData = snapshot.data ?? UserData();

        return Scaffold(
                // Scaffold - appBar
                appBar: AppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  title: Text(
                    _screens[_selected]['title'],
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),

                // Scaffold - drawer
                endDrawer: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Drawer(
                    child: ListTileTheme(
                      child: Column(
                        children: <Widget>[
                          // User data display
                          UserAccountsDrawerHeader(
                            currentAccountPicture: CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            accountName: Text(
                              userData != null ? userData.name : 'Name',
                              style: TextStyle(fontSize: 24.0),
                            ),
                            accountEmail: Text(
                              userData != null ? userData.email : 'email',
                              style: TextStyle(fontSize: 13.0),
                            ),
                          ),

                          // Dashboard
                          Container(
                            color: _selected == DrawerEnum.dashboard
                                ? Theme.of(context).primaryColorLight
                                : null,
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.dashboard),
                              title:
                                  Text(_screens[DrawerEnum.dashboard]['title']),
                              selected: _selected == DrawerEnum.dashboard
                                  ? true
                                  : false,
                              onTap: () {
                                setState(
                                    () => _selected = DrawerEnum.dashboard);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),

                          Divider(thickness: 1.0),

                          // Group
                          Container(
                            color: _selected == DrawerEnum.group
                                ? Theme.of(context).primaryColorLight
                                : null,
                            child: ListTile(
                              dense: true,
                              leading: Icon(FontAwesomeIcons.users),
                              title: Text(_screens[DrawerEnum.group]['title']),
                              selected:
                                  _selected == DrawerEnum.group ? true : false,
                              onTap: () {
                                setState(() => _selected = DrawerEnum.group);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),

                          // Timetable
                          Container(
                            color: _selected == DrawerEnum.timetable
                                ? Theme.of(context).primaryColorLight
                                : null,
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.table_chart),
                              title:
                                  Text(_screens[DrawerEnum.timetable]['title']),
                              selected: _selected == DrawerEnum.timetable
                                  ? true
                                  : false,
                              onTap: () {
                                setState(
                                    () => _selected = DrawerEnum.timetable);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),

                          // Classes
                          Container(
                            color: _selected == DrawerEnum.classes
                                ? Theme.of(context).primaryColorLight
                                : null,
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.school),
                              title:
                                  Text(_screens[DrawerEnum.classes]['title']),
                              selected: _selected == DrawerEnum.classes
                                  ? true
                                  : false,
                              onTap: () {
                                setState(() => _selected = DrawerEnum.classes);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),

                          // People
                          Container(
                            color: _selected == DrawerEnum.people
                                ? Theme.of(context).primaryColorLight
                                : null,
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.people),
                              title: Text(_screens[DrawerEnum.people]['title']),
                              selected:
                                  _selected == DrawerEnum.people ? true : false,
                              onTap: () {
                                setState(() => _selected = DrawerEnum.people);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),

                          // Profile
                          Container(
                            color: _selected == DrawerEnum.profile
                                ? Theme.of(context).primaryColorLight
                                : null,
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.person),
                              title:
                                  Text(_screens[DrawerEnum.profile]['title']),
                              selected: _selected == DrawerEnum.profile
                                  ? true
                                  : false,
                              onTap: () {
                                setState(() => _selected = DrawerEnum.profile);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),

                          Divider(thickness: 1.0),

                          // Settings
                          Container(
                            color: _selected == DrawerEnum.settings
                                ? Theme.of(context).primaryColorLight
                                : null,
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.settings),
                              title:
                                  Text(_screens[DrawerEnum.settings]['title']),
                              selected: _selected == DrawerEnum.settings
                                  ? true
                                  : false,
                              onTap: () {
                                setState(() => _selected = DrawerEnum.settings);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),

                          // Logout
                          Container(
                            color: _selected == DrawerEnum.logout
                                ? Theme.of(context).primaryColorLight
                                : null,
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.exit_to_app),
                              title: Text(_screens[DrawerEnum.logout]['title']),
                              selected:
                                  _selected == DrawerEnum.logout ? true : false,
                              onTap: () {
                                //setState(() => _selected = DrawerEnum.logout);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text('Do you want to logout?'),
                                      actions: <Widget>[
                                        // CANCEL button
                                        FlatButton(
                                          child: Text('CANCEL'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        // OK button
                                        FlatButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            // pop AlertDialog
                                            Navigator.of(context).pop();
                                            // pop Drawer
                                            Navigator.of(context).pop();

                                            _authService.logOut();

                                            // ThemeProvider.controllerOf(context).setTheme('default');
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

                // Scaffold - body
                body: () {
                  return _screens[_selected]['screen'];
                }(),
              );
      },
    );
  }
}
