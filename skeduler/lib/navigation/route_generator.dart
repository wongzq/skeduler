import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/navigation/custom_transition_route.dart';
import 'package:skeduler/navigation/wrapper.dart';
import 'package:skeduler/screens/home/dashboard_components/create_group.dart';
import 'package:skeduler/screens/home/dashboard_components/dashboard_screen.dart';
import 'package:skeduler/screens/home/group_components/edit_group.dart';
import 'package:skeduler/screens/home/group_components/group_screen.dart';
import 'package:skeduler/screens/home/members_components/members_screen.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/availability_editor.dart';
import 'package:skeduler/screens/home/my_schedule_components/my_schedule_screen.dart';
import 'package:skeduler/screens/home/settings_components/settings_screen.dart';
import 'package:skeduler/screens/home/subjects_components/subjects_screen.dart';
import 'package:skeduler/screens/home/timetable_components/new_timetable.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_editor.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_screen.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_settings/axis_custom_reorder.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_settings/timetable_settings.dart';
import 'package:skeduler/shared/widgets/add_availability.dart';
import 'package:skeduler/shared/widgets/add_subject.dart';
import 'package:skeduler/shared/widgets/edit_member.dart';
import 'package:skeduler/shared/widgets/edit_subject.dart';
import 'package:skeduler/shared/widgets/add_dummy.dart';
import 'package:skeduler/shared/widgets/add_member.dart';

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

      case '/timetables':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(TimetableScreen()));
        }
        break;

      case '/timetables/newTimetable':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(NewTimetable()));
        }
        break;

      case '/timetables/editor':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(TimetableEditor()));
        }
        break;

      case '/timetables/editor/settings':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(TimetableSettings()));
        }
        break;

      case '/timetables/editor/settings/reorderAxisCustom':
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

      case '/schedules':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeScale(
              page: wrapWidget(MyScheduleScreen()));
        }
        break;

      case '/schedules/addAvailability':
        if (args is RouteArgs) {
          return CustomTransitionRoute.fadeSlideRight(
              page: wrapWidget(AddAvailability()));
        }
        break;

      case '/schedules/availabilityEditor':
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
