import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen_options_owner.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen_options_admin.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen_options_member.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/ui_settings.dart';

class GroupScreen extends StatefulWidget {
  final void Function({String groupName}) refresh;

  const GroupScreen({Key key, this.refresh}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                'Group',
                style: textStyleAppBarTitle,
              ),
            ),
            drawer: HomeDrawer(DrawerEnum.group),
          )
        : StreamBuilder(
            stream: dbService.streamGroupMemberMe(groupStatus.group.docId),
            builder: (context, snapshot) {
              Member me = snapshot != null ? snapshot.data : null;

              return snapshot == null || snapshot.data == null
                  ? Loading()
                  : Scaffold(
                      appBar: AppBar(
                        title: groupStatus.group.name == null
                            ? Text(
                                'Group',
                                style: textStyleAppBarTitle,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    groupStatus.group.name,
                                    style: textStyleAppBarTitle,
                                  ),
                                  Text(
                                    'Group',
                                    style: textStyleBody,
                                  )
                                ],
                              ),
                      ),
                      drawer: HomeDrawer(DrawerEnum.group),
                      floatingActionButton: me != null
                          ? () {
                              if (me.role == MemberRole.owner)
                                return GroupScreenOptionsOwner();
                              else if (me.role == MemberRole.admin)
                                return GroupScreenOptionsAdmin();
                              else if (me.role == MemberRole.member)
                                return GroupScreenOptionsMember();
                              else
                                return Container();
                            }()
                          : Container(),
                      body: me != null && me.role == MemberRole.pending
                          ? Container()
                          : Container(
                              padding: EdgeInsets.all(20.0),
                              alignment: Alignment.topLeft,
                              child: Text(
                                groupStatus.group.description,
                                style: textStyleBody,
                              ),
                            ),
                    );
            },
          );
  }
}
