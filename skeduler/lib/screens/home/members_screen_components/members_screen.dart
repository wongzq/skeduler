import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/screens/home/members_screen_components/member_list_tile.dart';
import 'package:skeduler/screens/home/members_screen_components/members_screen_options_admin.dart';
import 'package:skeduler/screens/home/members_screen_components/members_screen_options_member.dart';
import 'package:skeduler/screens/home/members_screen_components/members_screen_options_owner.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/ui_settings.dart';

class MembersScreen extends StatefulWidget {
  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Loading()
        : StreamBuilder(
            stream: dbService.streamGroupMembers(groupStatus.group.docId),
            builder: (context, snapshot) {
              List<Member> members = snapshot != null ? snapshot.data : null;

              return members == null || members.isEmpty
                  ? Scaffold(
                      appBar: AppBar(
                        title: groupStatus.group.name == null
                            ? Text(
                                'Members',
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
                                    'Members',
                                    style: textStyleBody,
                                  )
                                ],
                              ),
                      ),
                      drawer: HomeDrawer(DrawerEnum.members),
                    )
                  : groupStatus.me == null
                      ? Loading()
                      : Scaffold(
                          appBar: AppBar(
                            title: groupStatus.group.name == null
                                ? Text(
                                    'Members',
                                    style: textStyleAppBarTitle,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        groupStatus.group.name,
                                        style: textStyleAppBarTitle,
                                      ),
                                      Text(
                                        'Members',
                                        style: textStyleBody,
                                      )
                                    ],
                                  ),
                          ),
                          drawer: HomeDrawer(DrawerEnum.members),
                          floatingActionButton:
                              groupStatus.me.role == MemberRole.owner
                                  ? MembersScreenOptionsOwner()
                                  : groupStatus.me.role == MemberRole.admin
                                      ? MembersScreenOptionsAdmin()
                                      : groupStatus.me.role == MemberRole.member
                                          ? MembersScreenOptionsMember()
                                          : Container(),
                          body: ListView.builder(
                            physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemCount: members != null ? members.length : 0,
                            itemBuilder: (context, index) {
                              if (members != null) {
                                members.sort((a, b) =>
                                    b.role.index.compareTo(a.role.index));
                                return MemberListTile(
                                  me: groupStatus.me,
                                  member: members[index],
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        );
            },
          );
  }
}
