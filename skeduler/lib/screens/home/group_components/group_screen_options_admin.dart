import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/navigation/route_arguments.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class GroupScreenOptionsAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);

    return SpeedDial(
      foregroundColor: getFABIconForegroundColor(context),
      backgroundColor: getFABIconBackgroundColor(context),
      overlayColor: Colors.grey,
      overlayOpacity: 0.8,
      curve: Curves.easeOutCubic,
      animatedIcon: AnimatedIcons.menu_close,
      children: <SpeedDialChild>[
        // Delete group
        SpeedDialChild(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          child: Icon(
            Icons.exit_to_app,
            size: 25.0,
          ),
          labelWidget: Container(
            height: 40.0,
            width: 150.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Text(
              'EXIT GROUP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),
          onTap: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleAlertDialog(
                  context: context,
                  contentDisplay: 'Exit \'${groupStatus.group.name}\' group?',
                  cancelDisplay: 'CANCEL',
                  cancelFunction: () {
                    Navigator.of(context).maybePop();
                  },
                  confirmDisplay: 'EXIT',
                  confirmFunction: () async {
                    await dbService.leaveGroup(groupStatus.group.docId);
                    groupStatus.reset();
                    ttbStatus.reset();
                    groupDocId.value = null;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                );
              },
            );
          },
        ),

        SpeedDialChild(
          backgroundColor: Colors.white.withOpacity(0),
          elevation: 0,
        ),

        // Edit group information
        SpeedDialChild(
          foregroundColor: getFABIconForegroundColor(context),
          backgroundColor: getFABIconBackgroundColor(context),
          child: Icon(
            Icons.edit,
            size: 30.0,
          ),
          labelWidget: Container(
            height: 40.0,
            width: 150.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: getFABIconBackgroundColor(context),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Text(
              'EDIT INFO',
              style: TextStyle(
                color: getFABTextColor(context),
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/group/edit',
              arguments: RouteArgsGroup(group: groupStatus.group),
            );
          },
        ),

        // Add subject
        SpeedDialChild(
          foregroundColor: getFABIconForegroundColor(context),
          backgroundColor: getFABIconBackgroundColor(context),
          child: Icon(
            Icons.class_,
            size: 30.0,
          ),
          labelWidget: Container(
            height: 40.0,
            width: 150.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: getFABIconBackgroundColor(context),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Text(
              'ADD SUBJECT',
              style: TextStyle(
                color: getFABTextColor(context),
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),
          onTap: () async {
            Navigator.of(context).pushNamed(
              '/subjects/addSubject',
              arguments: RouteArgs(),
            );
          },
        ),

        // Add member
        SpeedDialChild(
          foregroundColor: getFABIconForegroundColor(context),
          backgroundColor: getFABIconBackgroundColor(context),
          child: Icon(
            Icons.person_add,
            size: 25.0,
          ),
          labelWidget: Container(
            height: 40.0,
            width: 150.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: getFABIconBackgroundColor(context),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Text(
              'ADD MEMBER',
              style: TextStyle(
                color: getFABTextColor(context),
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/group/addMember',
              arguments: RouteArgs(),
            );
          },
        ),
      ],
    );
  }
}
