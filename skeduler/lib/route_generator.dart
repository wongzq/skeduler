import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/create_group.dart';
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
import 'package:skeduler/wrapper.dart';
import 'package:skeduler/shared/components/add_dummy.dart';
import 'package:skeduler/shared/components/add_member.dart';
import 'package:skeduler/shared/components/custom_transition_route.dart';

////////////////////////////////////////////////////////////////////////////////
/// Route Generator class
////////////////////////////////////////////////////////////////////////////////
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    /// getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/dashboard':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false)
              .add(DrawerEnum.dashboard);
          return CustomTransitionRoute(page: wrapWidget(DashboardScreen()));
        } else if (args == null) {
          return CustomTransitionRoute(page: wrapWidget(DashboardScreen()));
        }
        break;

      case '/dashboard/createGroup':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false)
              .add(DrawerEnum.dashboard);
          return CustomTransitionRoute(page: wrapWidget(CreateGroup()));
        }
        break;

      case '/group':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false).add(DrawerEnum.group);
          return CustomTransitionRoute(page: wrapWidget(GroupScreen()));
        }
        break;

      case '/group/edit':
        if (args is RouteArgsGroup) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false).add(DrawerEnum.group);
          return CustomTransitionRoute(page: wrapWidget(EditGroup(args.group)));
        }
        break;

      case '/group/addMember':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false).add(DrawerEnum.group);
          return CustomTransitionRoute(page: wrapWidget(AddMember()));
        }
        break;

      case '/group/addDummy':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false).add(DrawerEnum.group);
          return CustomTransitionRoute(page: wrapWidget(AddDummy()));
        }
        break;

      case '/members':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false).add(DrawerEnum.members);
          return CustomTransitionRoute(page: wrapWidget(MembersScreen()));
        }
        break;

      case '/timetable':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false)
              .add(DrawerEnum.timetable);
          return CustomTransitionRoute(page: wrapWidget(TimetableScreen()));
        }
        break;

      case '/timetable/editor':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false)
              .add(DrawerEnum.timetable);
          return CustomTransitionRoute(page: wrapWidget(TimetableEditor()));
        }
        break;

      case '/timetable/editor/settings':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false)
              .add(DrawerEnum.timetable);
          return CustomTransitionRoute(page: wrapWidget(TimetableSettings()));
        }
        break;

      case '/timetable/editor/settings/reorderAxisCustom':
        if (args is RouteArgsReorderAxisCustom) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false)
              .add(DrawerEnum.timetable);
          return CustomTransitionRoute(
            page: wrapWidget(
              AxisCustomReoder(
                axisCustom: args.axisCustom,
                valSetAxisCustom: args.valSetAxisCustom,
              ),
            ),
          );
        }
        break;

      case '/mySchedule':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false)
              .add(DrawerEnum.mySchedule);
          return CustomTransitionRoute(page: wrapWidget(MyScheduleScreen()));
        }
        break;

      case '/mySchedule/scheduleEditor':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false)
              .add(DrawerEnum.mySchedule);
          return CustomTransitionRoute(page: wrapWidget(ScheduleEditor()));
        }
        break;

      case '/settings':
        if (args is RouteArgs) {
          Provider.of<DrawerEnumHistory>(args.context, listen: false).add(DrawerEnum.settings);
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
