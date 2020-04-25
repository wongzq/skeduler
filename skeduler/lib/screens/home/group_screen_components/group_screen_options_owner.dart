import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';

class GroupScreenOptionsOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<DrawerEnum> selected =
        Provider.of<ValueNotifier<DrawerEnum>>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return StreamBuilder(
        stream: dbService.getGroup(groupDocId.value),
        builder: (context, snapshot) {
          Group group = snapshot.data;

          return SpeedDial(
            foregroundColor: getFABIconForegroundColor(context),
            backgroundColor: getFABIconBackgroundColor(context),
            overlayColor: Colors.grey,
            overlayOpacity: 0.8,
            curve: Curves.easeOutCubic,
            animatedIcon: AnimatedIcons.menu_close,

            /// Delete group
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
                                        hintText: 'type \'' +
                                            group.name +
                                            '\' to delete'),
                                    validator: (value) {
                                      if (value == group.name) {
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
                                Navigator.pop(context);
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
                                  dbService.deleteGroup(group.groupDocId);
                                  groupDocId.value = null;
                                  selected.value = DrawerEnum.dashboard;
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
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

              /// Edit group information
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
                  Navigator.of(context)
                      .pushNamed('/group/edit', arguments: group);
                },
              ),

              /// Add subject
              SpeedDialChild(
                foregroundColor: getFABIconForegroundColor(context),
                backgroundColor: getFABIconBackgroundColor(context),
                child: Icon(
                  Icons.school,
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
                onTap: () {},
              ),

              /// Add member
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
                  Navigator.of(context).pushNamed('/group/addMember');
                },
              ),
            ],
          );
        });
  }
}
