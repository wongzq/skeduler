import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/dashboard_screen.dart';
import 'package:skeduler/screens/home/group_screen_components/edit_group.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen.dart';
import 'package:skeduler/screens/home/members_screen_components/members_screen.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/my_schedule_screen.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/schedule_editor.dart';
import 'package:skeduler/screens/home/settings_screen_components/settings_screen.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_editor.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_screen.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/axis_custom_reorder.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/timetable_settings.dart';
import 'package:skeduler/screens/wrapper.dart';
import 'package:skeduler/shared/components/add_dummy.dart';
import 'package:skeduler/shared/components/add_member.dart';
import 'package:skeduler/shared/components/custom_transition_route.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    /// getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/dashboard':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(DashboardScreen()));
        }
        break;

      case '/group':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(GroupScreen()));
        }
        break;

      case '/group/edit':
        if (args is Group) {
          return CustomTransitionRoute(page: wrapWidget(EditGroup(args)));
        }
        break;

      case '/group/addMember':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(AddMember()));
        }
        break;

      case '/group/addDummy':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(AddDummy()));
        }
        break;

      case '/members':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(MembersScreen()));
        }
        break;

      case '/timetable':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(TimetableScreen()));
        }
        break;

      case '/timetable/editor':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(TimetableEditor()));
        }
        break;

      case '/timetable/editor/settings':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(TimetableSettings()));
        }
        break;

      case '/timetable/editor/settings/reorderAxisCustom':
        if (args is Map<String, dynamic>) {
          return CustomTransitionRoute(
            page: wrapWidget(
              AxisCustomReoder(
                axisCustom: args['axisCustom'],
                valSetAxisCustom: args['valSetAxisCustom'],
              ),
            ),
          );
        }
        break;

      case '/mySchedule':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(MyScheduleScreen()));
        }
        break;

      case '/mySchedule/scheduleEditor':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(ScheduleEditor()));
        }
        break;

      case '/settings':
        if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(SettingsScreen()));
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
