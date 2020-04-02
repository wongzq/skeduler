import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group.dart';
import 'package:skeduler/screens/home/group_screen_components/edit_group.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/add_person.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/ui_settings.dart';

class GroupScreen extends StatefulWidget {
  final void Function({String groupName}) refresh;

  const GroupScreen({this.refresh});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  String _groupName;

  @override
  void initState() {
    SchedulerBinding.instance
        .addPostFrameCallback((_) => widget.refresh(groupName: _groupName));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService _dbService = Provider.of<DatabaseService>(context);
    GroupMetadata _groupMeta = Provider.of<GroupMetadata>(context);

    return StreamBuilder(
        stream: _dbService.getGroup(_groupMeta.docId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Group _group = snapshot.data ?? null;
          if (snapshot.data != null) {
            _groupName = _group.name;
            // widget.refresh();
          }

          return snapshot.data == null
              ? Loading()
              : Stack(
                  children: <Widget>[
                    // Text: Group name
                    Container(
                      padding: EdgeInsets.all(20.0),
                      alignment: Alignment.topLeft,
                      child: Text(
                        _group.description,
                        style: textStyleBody,
                      ),
                    ),

                    // SpeedDial: Options
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: 20.0, right: 20.0),
                        child: SpeedDial(
                          backgroundColor: Theme.of(context).primaryColor,
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
                              onTap: () {},
                            ),

                            SpeedDialChild(
                              backgroundColor: Colors.white.withOpacity(0),
                              elevation: 0,
                            ),

                            // Edit group information
                            SpeedDialChild(
                              backgroundColor:
                                  Theme.of(context).primaryColorDark,
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
                                  color: Theme.of(context).primaryColorDark,
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditGroup(_group),
                                  ),
                                );
                              },
                            ),

                            // Add subject
                            SpeedDialChild(
                              backgroundColor:
                                  Theme.of(context).primaryColorDark,
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
                                  color: Theme.of(context).primaryColorDark,
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
                              backgroundColor:
                                  Theme.of(context).primaryColorDark,
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
                                  color: Theme.of(context).primaryColorDark,
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPerson(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
        });
  }
}
