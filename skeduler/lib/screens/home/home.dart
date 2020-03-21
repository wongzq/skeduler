import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/drawer_enum.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/home/classes_screen.dart';
import 'package:skeduler/screens/home/dashboard_screen.dart';
import 'package:skeduler/screens/home/groups_screen.dart';
import 'package:skeduler/screens/home/people_screen.dart';
import 'package:skeduler/screens/home/profile_screen.dart';
import 'package:skeduler/screens/home/settings_screen.dart';
import 'package:skeduler/screens/home/timetable_screen.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/loading.dart';

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
  DrawerEnum _selected = DrawerEnum.dashboard;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    DatabaseService _databaseService = DatabaseService(uid: user.uid);

    return StreamBuilder<UserData>(
      stream: _databaseService.userData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        UserData userData = snapshot.data ?? null;
        return Scaffold(
          // Scaffold - appBar
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
          ),

          // Scaffold - drawer
          drawer: Container(
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
                        title: Text('Dashboard'),
                        selected:
                            _selected == DrawerEnum.dashboard ? true : false,
                        onTap: () {
                          setState(() => _selected = DrawerEnum.dashboard);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    Divider(thickness: 1.0),

                    // Groups
                    Container(
                      color: _selected == DrawerEnum.groups
                          ? Theme.of(context).primaryColorLight
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.group_work),
                        title: Text('Groups'),
                        selected: _selected == DrawerEnum.groups ? true : false,
                        onTap: () {
                          setState(() => _selected = DrawerEnum.groups);
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
                        title: Text('Timetable'),
                        selected:
                            _selected == DrawerEnum.timetable ? true : false,
                        onTap: () {
                          setState(() => _selected = DrawerEnum.timetable);
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
                        title: Text('Classes'),
                        selected:
                            _selected == DrawerEnum.classes ? true : false,
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
                        title: Text('People'),
                        selected: _selected == DrawerEnum.people ? true : false,
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
                        title: Text('Profile'),
                        selected:
                            _selected == DrawerEnum.profile ? true : false,
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
                        title: Text('Settings'),
                        selected:
                            _selected == DrawerEnum.settings ? true : false,
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
                        title: Text('Logout'),
                        selected: _selected == DrawerEnum.logout ? true : false,
                        onTap: () {
                          setState(() => _selected = DrawerEnum.logout);
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Text('Do you want to logout?'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('CANCEL'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _authService.logOut();
                                      },
                                    )
                                  ],
                                );
                              });
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
            switch (_selected) {
              case DrawerEnum.dashboard:
                return DashboardScreen();
                break;

              case DrawerEnum.groups:
                return GroupsScreen();
                break;

              case DrawerEnum.people:
                return PeopleScreen();
                break;

              case DrawerEnum.classes:
                return ClassesScreen();
                break;

              case DrawerEnum.timetable:
                return TimetableScreen();
                break;

              case DrawerEnum.profile:
                return ProfileScreen();
                break;

              case DrawerEnum.settings:
                return SettingsScreen();
                break;

              default:
                return Loading();
            }
          }(),
        );
      },
    );
  }
}
