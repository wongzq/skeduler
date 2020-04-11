import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/services/database_service.dart';

class MembersScreenOptionsAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return StreamBuilder<Object>(
        stream: dbService.getGroup(groupDocId.value),
        builder: (context, snapshot) {
          Group group = snapshot.data;

          return group == null
              ? Container()
              : Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
                    child: SpeedDial(
                      overlayColor: Colors.grey,
                      overlayOpacity: 0.8,
                      curve: Curves.easeOutCubic,
                      animatedIcon: AnimatedIcons.menu_close,

                      /// Exit group
                      children: <SpeedDialChild>[
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
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content:
                                        Text('Exit \'${group.name}\' group?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('CANCEL'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text(
                                          'EXIT',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        onPressed: () {
                                          dbService
                                              .leaveGroup(groupDocId.value);
                                          groupDocId.value = null;
                                          Navigator.popUntil(context,
                                              (route) => route.isFirst);
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),

                        /// Add member
                        SpeedDialChild(
                          child: Icon(
                            Icons.person_add,
                            size: 25.0,
                          ),
                          labelWidget: Container(
                            height: 40.0,
                            width: 150.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
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
                                color: Colors.black,
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
                    ),
                  ),
                );
        });
  }
}
