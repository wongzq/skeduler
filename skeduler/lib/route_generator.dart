import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/create_group.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/dashboard_screen.dart';
import 'package:skeduler/screens/home/group_screen_components/edit_group.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen.dart';
import 'package:skeduler/screens/home/members_screen_components/members_screen.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/availability_editor_components/availability_editor.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/my_schedule_screen.dart';
import 'package:skeduler/screens/home/settings_screen_components/settings_screen.dart';
import 'package:skeduler/screens/home/subjects_screen_components/subjects_screen.dart';
import 'package:skeduler/screens/home/timetable_screen_components/new_timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_editor.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_screen.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/axis_custom_reorder.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/timetable_settings.dart';
import 'package:skeduler/shared/components/add_subject.dart';
import 'package:skeduler/shared/components/edit_member.dart';
import 'package:skeduler/shared/components/edit_subject.dart';
import 'package:skeduler/wrapper.dart';
import 'package:skeduler/shared/components/add_dummy.dart';
import 'package:skeduler/shared/components/add_member.dart';
import 'package:skeduler/shared/components/custom_transition_route.dart';

// --------------------------------------------------------------------------------
// Route Generator class
// --------------------------------------------------------------------------------

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/dashboard':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(DashboardScreen()));
        } else if (args == null) {
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(DashboardScreen()));
        }
        break;

      case '/dashboard/createGroup':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(CreateGroup()));
        }
        break;

      case '/group':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(GroupScreen()));
        }
        break;

      case '/group/edit':
        if (args is RouteArgsGroup) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(EditGroup(group: args.group)));
        }
        break;

      case '/group/addMember':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(AddMember()));
        }
        break;

      case '/group/addDummy':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(AddDummy()));
        }
        break;

      case '/members':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(MembersScreen()));
        }
        break;

      case '/members/editMember':
        if (args is RouteArgsEditMember) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(EditMember(member: args.member)));
        }
        break;

      case '/subjects':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(SubjectsScreen()));
        }
        break;

      case '/subjects/addSubject':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(AddSubject()));
        }
        break;

      case '/subjects/editSubject':
        if (args is RouteArgsEditSubject) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(EditSubject(subject: args.subject)));
        }
        break;

      case '/timetable':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(TimetableScreen()));
        }
        break;

      case '/timetable/newTimetable':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(NewTimetable()));
        }
        break;

      case '/timetable/editor':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(TimetableEditor()));
        }
        break;

      case '/timetable/editor/settings':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(TimetableSettings()));
        }
        break;

      case '/timetable/editor/settings/reorderAxisCustom':
        if (args is RouteArgsReorderAxisCustom) {
          return CustomTransitionRoute.fadeSlideRight(
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
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(MyScheduleScreen()));
        }
        break;

      case '/mySchedule/scheduleEditor':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(AvailabilityEditor()));
        }
        break;

      case '/settings':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(SettingsScreen()));
        }
        break;

      default:
        return null;
    }
    return null;
  }
}
