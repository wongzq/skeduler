import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/dashboard_screen.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen.dart';
import 'package:skeduler/screens/wrapper.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Wrapper());
        break;

      case '/dashboard':
        if (args == null) {
          return MaterialPageRoute(builder: (_) => DashboardScreen());
        }
        break;

      case '/group':
        if (args is String) {
          return MaterialPageRoute(builder: (_) => GroupScreen());
        }
        break;

      default:
        return null;
    }
    return null;
  }
}