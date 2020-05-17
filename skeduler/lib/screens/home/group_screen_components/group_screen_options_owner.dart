import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';

class GroupScreenOptionsOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

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
          foregroundColor: getFABIconForegroundColor(context),
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
                color: getFABTextColor(context),
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete this group?'),
                    content: Row(
                      children: <Widget>[
                        Expanded(
                          child: Form(
                            key: formKey,
                            child: TextFormField(
                              autofocus: true,
                              decoration: InputDecoration(
                                  hintText:
                                      'type \'${groupStatus.group.name}\' to delete'),
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
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            dbService.deleteGroup(groupStatus.group.docId);
                            groupDocId.value = null;
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
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
            showDialog(
              context: context,
              builder: (dialogContext) {
                GlobalKey<FormState> formKey = GlobalKey<FormState>();
                String newSubjectName;
                String newSubjectNickname;

                return AlertDialog(
                  title: Text(
                    'New subject',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Subject short form (optional)',
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          onChanged: (value) =>
                              newSubjectNickname = value.trim(),
                          validator: (value) => null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Subject full name',
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          onChanged: (value) => newSubjectName = value.trim(),
                          validator: (value) =>
                              value == null || value.trim() == ''
                                  ? 'Subject name cannot be empty'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('CANCEL'),
                      onPressed: () => Navigator.of(dialogContext).maybePop(),
                    ),
                    FlatButton(
                      child: Text('SAVE'),
                      onPressed: () async {
                        if (formKey.currentState.validate()) {
                          Navigator.of(dialogContext).maybePop();

                          OperationStatus status =
                              await dbService.addGroupSubject(
                                  groupStatus.group.docId,
                                  Subject(
                                    name: newSubjectName,
                                    nickname: newSubjectNickname,
                                  ));

                          if (status.completed) {
                            Fluttertoast.showToast(
                              msg: status.message,
                              toastLength: Toast.LENGTH_LONG,
                            );
                          }

                          if (status.success) {
                            Navigator.of(context)
                                .pushNamed('/subjects', arguments: RouteArgs());
                          }
                        }
                      },
                    ),
                  ],
                );
              },
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
