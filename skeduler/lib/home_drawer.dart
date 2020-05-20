import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/main.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/user.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/widgets.dart';
import 'package:theme_provider/theme_provider.dart';

class HomeDrawer extends StatelessWidget {
  // properties
  final AuthService _authService = AuthService();
  final DrawerEnum _selected;

  final Map<DrawerEnum, Map<String, dynamic>> _screens = {
    DrawerEnum.dashboard: {'title': 'Dashboard', 'icon': null},
    DrawerEnum.group: {'title': 'No group selected', 'icon': null},
    DrawerEnum.timetable: {'title': 'Timetable', 'icon': null},
    DrawerEnum.subjects: {'title': 'Subjects', 'icon': null},
    DrawerEnum.members: {'title': 'Members', 'icon': null},
    DrawerEnum.mySchedule: {'title': 'My Schedule', 'icon': null},
    DrawerEnum.settings: {'title': 'Settings', 'icon': null},
    DrawerEnum.logout: {'title': 'Logout', 'icon': null},
  };

  // constructors
  HomeDrawer(this._selected);

  // methods
  Color _tileSelectedBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? null : null;

  Color _tileSelectedForegroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? getOriginThemeData(ThemeProvider.themeOf(context).id).primaryColor
          : getOriginThemeData(ThemeProvider.themeOf(context).id).accentColor;

  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    User user = Provider.of<User>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Drawer(
        child: ListTileTheme(
          selectedColor: _tileSelectedForegroundColor(context),
          child: Column(
            children: <Widget>[
              // User data display
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

              // Dashboard
              Container(
                color: _selected == DrawerEnum.dashboard
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.dashboard),
                  title: Text(_screens[DrawerEnum.dashboard]['title']),
                  selected: _selected == DrawerEnum.dashboard ? true : false,
                  onTap: () {
                    Navigator.of(context).popAndPushNamed(
                      '/dashboard',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              Divider(thickness: 1.0),

              // Group
              Container(
                color: _selected == DrawerEnum.group
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  leading: Icon(FontAwesomeIcons.users),
                  title: groupStatus.group != null
                      ? Text(groupStatus.group.name ??
                          _screens[DrawerEnum.group]['title'])
                      : Text(
                          _screens[DrawerEnum.group]['title'],
                        ),
                  selected: _selected == DrawerEnum.group ? true : false,
                  onTap: () {
                    Navigator.of(context).popAndPushNamed(
                      '/group',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              // Members
              Container(
                color: _selected == DrawerEnum.members
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  leading: Icon(Icons.people),
                  title: Text(_screens[DrawerEnum.members]['title']),
                  selected: _selected == DrawerEnum.members ? true : false,
                  onTap: () {
                    Navigator.of(context).popAndPushNamed(
                      '/members',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              // Subjects
              Container(
                color: _selected == DrawerEnum.subjects
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  leading: Icon(Icons.class_),
                  title: Text(_screens[DrawerEnum.subjects]['title']),
                  selected: _selected == DrawerEnum.subjects ? true : false,
                  onTap: () {
                    Navigator.of(context).popAndPushNamed(
                      '/subjects',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              // Timetable
              Container(
                color: _selected == DrawerEnum.timetable
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  leading: Icon(Icons.table_chart),
                  title: Text(_screens[DrawerEnum.timetable]['title']),
                  selected: _selected == DrawerEnum.timetable ? true : false,
                  onTap: () {
                    Navigator.of(context).popAndPushNamed(
                      '/timetable',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              // My Schedule
              Container(
                color: _selected == DrawerEnum.mySchedule
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  leading: Icon(Icons.schedule),
                  title: Text(_screens[DrawerEnum.mySchedule]['title']),
                  selected: _selected == DrawerEnum.mySchedule ? true : false,
                  onTap: () {
                    Navigator.of(context).popAndPushNamed(
                      '/mySchedule',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),
              Divider(thickness: 1.0),

              // Settings
              Container(
                color: _selected == DrawerEnum.settings
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.settings),
                  title: Text(_screens[DrawerEnum.settings]['title']),
                  selected: _selected == DrawerEnum.settings ? true : false,
                  onTap: () {
                    Navigator.of(context).popAndPushNamed(
                      '/settings',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              // Logout
              Container(
                color: _selected == DrawerEnum.logout
                    ? _tileSelectedBackgroundColor(context)
                    : null,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.exit_to_app),
                  title: Text(_screens[DrawerEnum.logout]['title']),
                  selected: _selected == DrawerEnum.logout ? true : false,
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleAlertDialog(
                          context: context,
                          contentDisplay: 'Do you want to logout?',
                          confirmDisplay: 'YES',
                          cancelDisplay: 'NO',
                          confirmFunction: () async {
                            _authService.logOut();
                            RestartWidget.restartApp(context);
                          },
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
