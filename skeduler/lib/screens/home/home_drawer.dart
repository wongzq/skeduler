import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/main.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/user.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

class HomeDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();

  final Map<DrawerEnum, Map<String, dynamic>> _screens = {
    DrawerEnum.dashboard: {'title': 'Dashboard', 'icon': null},
    DrawerEnum.group: {'title': 'No group selected', 'icon': null},
    DrawerEnum.timetable: {'title': 'Timetable', 'icon': null},
    DrawerEnum.classes: {'title': 'Subjects', 'icon': null},
    DrawerEnum.members: {'title': 'Members', 'icon': null},
    DrawerEnum.mySchedule: {'title': 'My Schedule', 'icon': null},
    DrawerEnum.settings: {'title': 'Settings', 'icon': null},
    DrawerEnum.logout: {'title': 'Logout', 'icon': null},
  };

  Color _tileSelectedBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? null : null;

  Color _tileSelectedForegroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? getOriginThemeData(ThemeProvider.themeOf(context).id).primaryColor
          : getOriginThemeData(ThemeProvider.themeOf(context).id).accentColor;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<DrawerEnum> selected =
        Provider.of<ValueNotifier<DrawerEnum>>(context);
    ValueNotifier<Group> group = Provider.of<ValueNotifier<Group>>(context);

    User user = Provider.of<User>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Drawer(
        child: ListTileTheme(
          selectedColor: _tileSelectedForegroundColor(context),
          child: Column(
            children: <Widget>[
              /// User data display
              Container(
                height: 150.0,
                child: UserAccountsDrawerHeader(
                  accountName: Text(
                    user != null ? user.name : 'Name',
                    style: TextStyle(fontSize: 24.0),
                  ),
                  accountEmail: Text(
                    user != null ? user.email : 'email',
                    style: TextStyle(fontSize: 13.0),
                  ),
                ),
              ),

              /// Dashboard
              Container(
                color: selected.value == DrawerEnum.dashboard
                    ? _tileSelectedBackgroundColor(context)
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
              Container(
                color: selected.value == DrawerEnum.group
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: group.value != null ? true : false,
                  dense: true,
                  leading: Icon(FontAwesomeIcons.users),
                  title: group.value != null
                      ? Text(group.value.name ??
                          _screens[DrawerEnum.group]['title'])
                      : Text(
                          _screens[DrawerEnum.group]['title'],
                        ),
                  selected: selected.value == DrawerEnum.group ? true : false,
                  onTap: () {
                    selected.value = DrawerEnum.group;
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/group');
                  },
                ),
              ),

              /// members
              Container(
                color: selected.value == DrawerEnum.members
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: group.value != null ? true : false,
                  dense: true,
                  leading: Icon(Icons.people),
                  title: Text(_screens[DrawerEnum.members]['title']),
                  selected: selected.value == DrawerEnum.members ? true : false,
                  onTap: () {
                    selected.value = DrawerEnum.members;
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/members');
                  },
                ),
              ),

              /// Classes
              Container(
                color: selected.value == DrawerEnum.classes
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: group.value != null ? true : false,
                  dense: true,
                  leading: Icon(Icons.class_),
                  title: Text(_screens[DrawerEnum.classes]['title']),
                  selected: selected.value == DrawerEnum.classes ? true : false,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),

              /// Timetable
              Container(
                color: selected.value == DrawerEnum.timetable
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: group.value != null ? true : false,
                  dense: true,
                  leading: Icon(Icons.table_chart),
                  title: Text(_screens[DrawerEnum.timetable]['title']),
                  selected:
                      selected.value == DrawerEnum.timetable ? true : false,
                  onTap: () {
                    selected.value = DrawerEnum.timetable;
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/timetable');
                  },
                ),
              ),

              /// My Schedule
              Container(
                color: selected.value == DrawerEnum.mySchedule
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: group.value != null ? true : false,
                  dense: true,
                  leading: Icon(Icons.schedule),
                  title: Text(_screens[DrawerEnum.mySchedule]['title']),
                  selected:
                      selected.value == DrawerEnum.mySchedule ? true : false,
                  onTap: () {
                    selected.value = DrawerEnum.mySchedule;
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/mySchedule');
                  },
                ),
              ),
              Divider(thickness: 1.0),

              /// Settings
              Container(
                color: selected.value == DrawerEnum.settings
                    ? _tileSelectedBackgroundColor(context)
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
                    ? _tileSelectedBackgroundColor(context)
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
