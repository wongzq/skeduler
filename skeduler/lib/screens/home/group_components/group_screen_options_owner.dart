import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/navigation/route_arguments.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';

class GroupScreenOptionsOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return SpeedDial(
      foregroundColor: getFABIconForegroundColor(context),
      backgroundColor: getFABIconBackgroundColor(context),
      overlayColor: Colors.grey,
      overlayOpacity: 0.8,
      curve: Curves.easeOutCubic,
      animatedIcon: AnimatedIcons.menu_close,

      // Delete group
      children: <SpeedDialChild>[
        SpeedDialChild(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          child: Icon(
            Icons.delete,
            size: 30.0,
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
              'DELETE',
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
                  return AlertDialog(
                    title: Text(
                      'Delete this group?',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    content: Row(
                      children: <Widget>[
                        Expanded(
                          child: Form(
                            key: formKey,
                            child: TextFormField(
                              autofocus: true,
                              decoration: InputDecoration(
                                  hintText: groupStatus.group == null
                                      ? ''
                                      : 'type \'${groupStatus.group.name}\' to delete'),
                              validator: (value) {
                                if (value == groupStatus.group.name) {
                                  return null;
                                } else {
                                  return 'Group name doesn\'t match';
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('CANCEL'),
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                      ),
                      FlatButton(
                        child: Text(
                          'DELETE',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () async {
                          unfocus();

                          if (formKey.currentState.validate()) {
                            await dbService
                                .deleteGroup(groupStatus.group.docId)
                                .then((_) {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }).then((_) {
                              groupStatus.reset();
                              ttbStatus.reset();
                              groupDocId.value = null;
                            });
                          }
                        },
                      ),
                    ],
                  );
                });
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
          onTap: () {
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
