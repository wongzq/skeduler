import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/navigation/home_drawer.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_owner.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_admin.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_member.dart';
import 'package:skeduler/shared/widgets/loading.dart';
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
        ? Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: AppBarTitle(title: 'Group'),
                ),
                drawer: HomeDrawer(DrawerEnum.group),
              ),
              Loading(),
            ],
          )
        : Scaffold(
            appBar: AppBar(
              title: AppBarTitle(
                title: groupStatus.group.name,
                alternateTitle: 'Admin Panel',
                subtitle: 'Admin Panel',
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
            body: Container(),
          );
  }
}
