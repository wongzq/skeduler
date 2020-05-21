import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen_options_owner.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen_options_admin.dart';
import 'package:skeduler/screens/home/group_screen_components/group_screen_options_member.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class GroupScreen extends StatefulWidget {
  final void Function({String groupName}) refresh;

  const GroupScreen({Key key, this.refresh}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Scaffold(
            appBar: AppBar(title: AppBarTitle(title: 'Group')),
            drawer: HomeDrawer(DrawerEnum.group),
          )
        : groupStatus.me == null
            ? Loading()
            : Scaffold(
                appBar: AppBar(
                  title: AppBarTitle(
                    title: groupStatus.group.name,
                    alternateTitle: 'Group',
                    subtitle: 'Group',
                  ),
                ),
                drawer: HomeDrawer(DrawerEnum.group),
                floatingActionButton: groupStatus.me != null
                    ? () {
                        if (groupStatus.me.role == MemberRole.owner)
                          return GroupScreenOptionsOwner();
                        else if (groupStatus.me.role == MemberRole.admin)
                          return GroupScreenOptionsAdmin();
                        else if (groupStatus.me.role == MemberRole.member)
                          return GroupScreenOptionsMember();
                        else
                          return Container();
                      }()
                    : Container(),
                body: groupStatus.me != null &&
                        groupStatus.me.role == MemberRole.pending
                    ? Container()
                    : Container(
                        padding: EdgeInsets.all(20.0),
                        alignment: Alignment.topLeft,
                        child: Text(
                          groupStatus.group.description == null ||
                                  groupStatus.group.description.trim() == ''
                              ? 'No group description'
                              : groupStatus.group.description,
                          style: groupStatus.group.description == null ||
                                  groupStatus.group.description.trim() == ''
                              ? textStyleBody.copyWith(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                )
                              : textStyleBody,
                        ),
                      ),
              );
  }
}
