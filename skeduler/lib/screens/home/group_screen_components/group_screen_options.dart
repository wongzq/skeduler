import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';

class GroupScreenOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return StreamBuilder<Object>(
        stream: dbService.getGroup(groupDocId.value),
        builder: (context, snapshot) {
          Group group = snapshot.data;

          Color mainIconBackgroundColor;
          Color iconBackgroundColor;
          Color labelBackgroundColor;

          if (group != null) {
            mainIconBackgroundColor =
                getOriginThemeData(group.colorShade.themeId).primaryColor ??
                    defaultColor;
            iconBackgroundColor =
                getOriginThemeData(group.colorShade.themeId).primaryColorDark ??
                    defaultColor;
            labelBackgroundColor =
                getOriginThemeData(group.colorShade.themeId).primaryColorDark ??
                    defaultColor;
          }

          return Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
              child: SpeedDial(
                backgroundColor: mainIconBackgroundColor,
                overlayColor: Colors.grey,
                overlayOpacity: 0.8,
                curve: Curves.easeOutCubic,
                animatedIcon: AnimatedIcons.menu_close,
                animatedIconTheme: IconThemeData(color: Colors.white),

                /// Delete group
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
                          fontSize: 16.0,
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
                                      Navigator.pop(context);
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
                    backgroundColor: iconBackgroundColor,
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.edit,
                      size: 30.0,
                    ),
                    labelWidget: Container(
                      height: 40.0,
                      width: 150.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: labelBackgroundColor,
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
                          color: Colors.white,
                          fontSize: 16.0,
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
                    backgroundColor: iconBackgroundColor,
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.school,
                      size: 30.0,
                    ),
                    labelWidget: Container(
                      height: 40.0,
                      width: 150.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: labelBackgroundColor,
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
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    onTap: () {},
                  ),

                  /// Add member
                  SpeedDialChild(
                    backgroundColor: iconBackgroundColor,
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.person_add,
                      size: 25.0,
                    ),
                    labelWidget: Container(
                      height: 40.0,
                      width: 150.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: labelBackgroundColor,
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
                          color: Colors.white,
                          fontSize: 16.0,
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
              ),
            ),
          );
        });
  }
}
