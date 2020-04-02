import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/dashboard_screen.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen.dart';
import 'package:skeduler/screens/home/profile_screen_components/profile_screen.dart';
import 'package:skeduler/screens/home/settings_screen_components/settings_screen.dart';
import 'package:skeduler/screens/wrapper.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/dashboard':
        if (args == null) {
          return MaterialPageRoute(
              builder: (_) => wrapWidget(DashboardScreen()));
        }
        break;

      case '/group':
        if (args == null) {
          return MaterialPageRoute(builder: (_) => wrapWidget(GroupScreen()));
        }
        break;

      case '/profile':
        if (args == null) {
          return MaterialPageRoute(builder: (_) => wrapWidget(ProfileScreen()));
        }
        break;

      case '/settings':
        if (args == null) {
          return MaterialPageRoute(
              builder: (_) => wrapWidget(SettingsScreen()));
        }
        break;

      default:
        return null;
    }
    return null;
  }

  static Widget wrapWidget(Widget widget) {
    return Wrapper(widget);
  }
}
