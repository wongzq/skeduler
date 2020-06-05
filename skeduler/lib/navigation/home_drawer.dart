import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/main.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/user.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class HomeDrawer extends StatelessWidget {
  // properties
  final AuthService _authService = AuthService();
  final DrawerEnum _selected;

  final Map<DrawerEnum, Map<String, dynamic>> _screens = {
    DrawerEnum.dashboard: {
      'title': 'Dashboard',
      'icon': Icon(Icons.dashboard),
    },
    DrawerEnum.group: {
      'title': 'No group selected',
      'icon': Icon(Icons.developer_board),
    },
    DrawerEnum.timetables: {
      'title': 'Timetables',
      'icon': Icon(Icons.table_chart),
    },
    DrawerEnum.subjects: {
      'title': 'Subjects',
      'icon': Icon(Icons.class_),
    },
    DrawerEnum.members: {
      'title': 'Members',
      'icon': Icon(Icons.people),
    },
    DrawerEnum.schedules: {
      'title': 'Schedules',
      'icon': Icon(Icons.schedule),
    },
    DrawerEnum.settings: {
      'title': 'Settings',
      'icon': Icon(Icons.settings),
    },
    DrawerEnum.logout: {
      'title': 'Logout',
      'icon': Icon(Icons.exit_to_app),
    },
  };

  // constructors
  HomeDrawer(this._selected);

  // methods
  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    User user = Provider.of<User>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Drawer(
        child: ListTileTheme(
          selectedColor: Theme.of(context).brightness == Brightness.light
              ? originTheme.primaryColorDark
              : originTheme.accentColor,
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
                child: ListTile(
                  dense: true,
                  leading: _screens[DrawerEnum.dashboard]['icon'],
                  title: Text(_screens[DrawerEnum.dashboard]['title']),
                  selected: _selected == DrawerEnum.dashboard ? true : false,
                  onTap: () {
                    Navigator.of(context)
                        .popUntil((route) => !route.navigator.canPop());
                  },
                ),
              ),

              Divider(thickness: 1.0),

              // Group - Admin Panel
              Container(
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  trailing: groupStatus.me != null &&
                          (groupStatus.me.role == MemberRole.owner ||
                              groupStatus.me.role == MemberRole.admin)
                      ? _screens[DrawerEnum.group]['icon']
                      : null,
                  title: Text(
                    groupStatus.group != null
                        ? groupStatus.group.name ??
                            _screens[DrawerEnum.group]['title']
                        : _screens[DrawerEnum.group]['title'],
                    style: TextStyle(fontSize: 14.0),
                    overflow: TextOverflow.fade,
                  ),
                  selected: _selected == DrawerEnum.group ? true : false,
                  onTap: groupStatus.me != null &&
                          (groupStatus.me.role == MemberRole.owner ||
                              groupStatus.me.role == MemberRole.admin)
                      ? () {
                          Navigator.of(context)
                              .popUntil((route) => !route.navigator.canPop());
                          Navigator.of(context).pushNamed(
                            '/group',
                            arguments: RouteArgs(),
                          );
                        }
                      : null,
                ),
              ),

              // Timetable
              Container(
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  leading: _screens[DrawerEnum.timetables]['icon'],
                  title: Text(_screens[DrawerEnum.timetables]['title']),
                  selected: _selected == DrawerEnum.timetables ? true : false,
                  onTap: () {
                    Navigator.of(context)
                        .popUntil((route) => !route.navigator.canPop());
                    Navigator.of(context).pushNamed(
                      '/timetables',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              // Members
              Container(
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  leading: _screens[DrawerEnum.members]['icon'],
                  title: Text(_screens[DrawerEnum.members]['title']),
                  selected: _selected == DrawerEnum.members ? true : false,
                  onTap: () {
                    Navigator.of(context)
                        .popUntil((route) => !route.navigator.canPop());
                    Navigator.of(context).pushNamed(
                      '/members',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              // Subjects
              Container(
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  leading: _screens[DrawerEnum.subjects]['icon'],
                  title: Text(_screens[DrawerEnum.subjects]['title']),
                  selected: _selected == DrawerEnum.subjects ? true : false,
                  onTap: () {
                    Navigator.of(context)
                        .popUntil((route) => !route.navigator.canPop());
                    Navigator.of(context).pushNamed(
                      '/subjects',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              // Schedules
              Container(
                child: ListTile(
                  enabled: groupStatus.group != null ? true : false,
                  dense: true,
                  leading: _screens[DrawerEnum.schedules]['icon'],
                  title: Text(_screens[DrawerEnum.schedules]['title']),
                  selected: _selected == DrawerEnum.schedules ? true : false,
                  onTap: () {
                    Navigator.of(context)
                        .popUntil((route) => !route.navigator.canPop());
                    Navigator.of(context).pushNamed(
                      '/schedules',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              Divider(thickness: 1.0),

              // Settings
              Container(
                child: ListTile(
                  dense: true,
                  leading: _screens[DrawerEnum.settings]['icon'],
                  title: Text(_screens[DrawerEnum.settings]['title']),
                  selected: _selected == DrawerEnum.settings ? true : false,
                  onTap: () {
                    Navigator.of(context)
                        .popUntil((route) => !route.navigator.canPop());
                    Navigator.of(context).pushNamed(
                      '/settings',
                      arguments: RouteArgs(),
                    );
                  },
                ),
              ),

              // Logout
              Container(
                child: ListTile(
                  dense: true,
                  leading: _screens[DrawerEnum.logout]['icon'],
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
