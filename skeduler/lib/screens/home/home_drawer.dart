import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/main.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/user.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/services/database_service.dart';

class HomeDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();

  final Map<DrawerEnum, Map<String, dynamic>> _screens = {
    DrawerEnum.dashboard: {'title': 'Dashboard', 'icon': null},
    DrawerEnum.group: {'title': 'Select a group', 'icon': null},
    DrawerEnum.timetable: {'title': 'Timetable', 'icon': null},
    DrawerEnum.classes: {'title': 'Classes', 'icon': null},
    DrawerEnum.members: {'title': 'Members', 'icon': null},
    DrawerEnum.profile: {'title': 'Profile', 'icon': null},
    DrawerEnum.settings: {'title': 'Settings', 'icon': null},
    DrawerEnum.logout: {'title': 'Logout', 'icon': null},
  };

  @override
  Widget build(BuildContext context) {
    ValueNotifier<DrawerEnum> selected =
        Provider.of<ValueNotifier<DrawerEnum>>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);

    User user = Provider.of<User>(context);
    return Container(
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
                  selected:
                      selected.value == DrawerEnum.dashboard ? true : false,
                  onTap: () {
                    selected.value = DrawerEnum.dashboard;
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/dashboard');
                  },
                ),
              ),

              Divider(thickness: 1.0),

              /// Group
              StreamBuilder(
                  stream: dbService.getGroup(groupDocId.value),
                  builder: (context, snapshot) {
                    Group group = snapshot != null ? snapshot.data : null;

                    return Column(
                      children: <Widget>[
                        Container(
                          color: selected.value == DrawerEnum.group
                              ? Theme.of(context).primaryColorLight
                              : null,
                          child: ListTile(
                            enabled: group != null ? true : false,
                            dense: true,
                            leading: Icon(FontAwesomeIcons.users),
                            title: group != null
                                ? Text(group.name ??
                                    _screens[DrawerEnum.group]['title'])
                                : Text(
                                    _screens[DrawerEnum.group]['title'],
                                  ),
                            selected: selected.value == DrawerEnum.group
                                ? true
                                : false,
                            onTap: () {
                              selected.value = DrawerEnum.group;
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/group');
                            },
                          ),
                        ),

                        /// Timetable
                        Container(
                          color: selected.value == DrawerEnum.timetable
                              ? Theme.of(context).primaryColorLight
                              : null,
                          child: ListTile(
                            enabled: group != null ? true : false,
                            dense: true,
                            leading: Icon(Icons.table_chart),
                            title:
                                Text(_screens[DrawerEnum.timetable]['title']),
                            selected: selected.value == DrawerEnum.timetable
                                ? true
                                : false,
                            onTap: () {
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
                            enabled: group != null ? true : false,
                            dense: true,
                            leading: Icon(Icons.school),
                            title: Text(_screens[DrawerEnum.classes]['title']),
                            selected: selected.value == DrawerEnum.classes
                                ? true
                                : false,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),

                        /// members
                        Container(
                          color: selected.value == DrawerEnum.members
                              ? Theme.of(context).primaryColorLight
                              : null,
                          child: ListTile(
                            enabled: group != null ? true : false,
                            dense: true,
                            leading: Icon(Icons.people),
                            title: Text(_screens[DrawerEnum.members]['title']),
                            selected: selected.value == DrawerEnum.members
                                ? true
                                : false,
                            onTap: () {
                              selected.value = DrawerEnum.members;
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/members');
                            },
                          ),
                        ),

                        /// Profile
                        Container(
                          color: selected.value == DrawerEnum.profile
                              ? Theme.of(context).primaryColorLight
                              : null,
                          child: ListTile(
                            enabled: group != null ? true : false,
                            dense: true,
                            leading: Icon(Icons.person),
                            title: Text(_screens[DrawerEnum.profile]['title']),
                            selected: selected.value == DrawerEnum.profile
                                ? true
                                : false,
                            onTap: () {
                              selected.value = DrawerEnum.profile;
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/profile');
                            },
                          ),
                        ),
                        Divider(thickness: 1.0),
                      ],
                    );
                  }),

              /// Settings
              Container(
                color: selected.value == DrawerEnum.settings
                    ? Theme.of(context).primaryColorLight
                    : null,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.settings),
                  title: Text(_screens[DrawerEnum.settings]['title']),
                  selected:
                      selected.value == DrawerEnum.settings ? true : false,
                  onTap: () {
                    selected.value = DrawerEnum.settings;
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/settings');
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
                  selected: selected.value == DrawerEnum.logout ? true : false,
                  onTap: () {
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
                                _authService.logOut();
                                RestartWidget.restartApp(context);
                              },
                            ),
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
    );
  }
}
