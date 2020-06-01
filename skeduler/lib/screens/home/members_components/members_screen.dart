import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/navigation/home_drawer.dart';
import 'package:skeduler/screens/home/members_components/member_list_tile.dart';
import 'package:skeduler/screens/home/members_components/members_screen_options_admin.dart';
import 'package:skeduler/screens/home/members_components/members_screen_options_member.dart';
import 'package:skeduler/screens/home/members_components/members_screen_options_owner.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class MembersScreen extends StatefulWidget {
  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return Stack(
      children: <Widget>[
        groupStatus.group == null
            ? Stack(
                children: [
                  Scaffold(
                    appBar: AppBar(
                      title: AppBarTitle(
                        title: 'Group',
                        subtitle: 'Members',
                      ),
                    ),
                    drawer: HomeDrawer(DrawerEnum.members),
                  ),
                  Loading(),
                ],
              )
            : Scaffold(
                appBar: AppBar(
                  title: AppBarTitle(
                    title: groupStatus.group.name,
                    alternateTitle: 'Group',
                    subtitle: 'Members',
                  ),
                ),
                drawer: HomeDrawer(DrawerEnum.members),
                floatingActionButton: groupStatus.me.role == MemberRole.owner
                    ? MembersScreenOptionsOwner()
                    : groupStatus.me.role == MemberRole.admin
                        ? MembersScreenOptionsAdmin()
                        : groupStatus.me.role == MemberRole.member
                            ? MembersScreenOptionsMember()
                            : Container(),
                body: groupStatus.members == null || groupStatus.members.isEmpty
                    ? Container()
                    : ListView.builder(
                        physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: groupStatus.members != null
                            ? groupStatus.members.length
                            : 0,
                        itemBuilder: (context, index) {
                          if (groupStatus.members != null) {
                            groupStatus.members.sort(
                                (a, b) => b.role.index.compareTo(a.role.index));
                            return MemberListTile(
                              me: groupStatus.me,
                              member: groupStatus.members[index],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
              ),
      ],
    );
  }
}
