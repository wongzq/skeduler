import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/conflict.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/navigation/home_drawer.dart';
import 'package:skeduler/screens/home/group_components/conflict_list_tile.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_owner.dart';
import 'package:skeduler/screens/home/group_components/group_screen_options_admin.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class GroupScreen extends StatefulWidget {
  final void Function({String groupName}) refresh;

  const GroupScreen({Key key, this.refresh}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  GroupStatus _groupStatus;

  ConflictSort _sortBy = ConflictSort.date;

  List<Widget> _generateActions() {
    return [
      PopupMenuButton(
        icon: Icon(Icons.sort),
        itemBuilder: (context) => [
          PopupMenuItem(value: ConflictSort.date, child: Text('Sort by date')),
          PopupMenuItem(
              value: ConflictSort.member, child: Text('Sort by member'))
        ],
        onSelected: (value) =>
            setState(() => _sortBy = value ?? ConflictSort.date),
      )
    ];
  }

  List<Conflict> _sortConflicts(List<Conflict> conflicts) {
    if (_sortBy == ConflictSort.date) {
      conflicts.sort((a, b) =>
          a.conflictDates.length == 0 && b.conflictDates.length == 0
              ? 0
              : a.conflictDates.length == 0 && b.conflictDates.length > 0
                  ? -1
                  : a.conflictDates.length > 0 && b.conflictDates.length == 0
                      ? 1
                      : a.conflictDates.first.compareTo(b.conflictDates.first));
    } else if (_sortBy == ConflictSort.member) {
      conflicts.sort((a, b) {
        return a.gridData.dragData.member.docId
            .compareTo(b.gridData.dragData.member.docId);
      });
    }

    return conflicts;
  }

  @override
  Widget build(BuildContext context) {
    _groupStatus = Provider.of<GroupStatus>(context);

    List<Conflict> conflicts = _sortConflicts(Conflict.generateConflicts(
        timetables: _groupStatus.timetables, members: _groupStatus.members));

    return _groupStatus.group == null
        ? Stack(children: <Widget>[
            Scaffold(
                appBar: AppBar(title: AppBarTitle(title: 'Group')),
                drawer: HomeDrawer(DrawerEnum.group)),
            Loading()
          ])
        : Scaffold(
            appBar: AppBar(
                title: AppBarTitle(
                    title: _groupStatus.group.name,
                    alternateTitle: 'Admin Panel',
                    subtitle: 'Admin Panel'),
                actions: _generateActions()),
            drawer: HomeDrawer(DrawerEnum.group),
            floatingActionButton: _groupStatus.me == null
                ? null
                : _groupStatus.me.role == MemberRole.owner
                    ? GroupScreenOptionsOwner()
                    : _groupStatus.me.role == MemberRole.admin
                        ? GroupScreenOptionsAdmin()
                        : null,
            body: conflicts.length == 0
                ? EmptyPlaceholder(
                    iconData: Icons.schedule, text: 'No schedule conflicts')
                : ListView.builder(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: conflicts.length,
                    itemBuilder: (context, index) =>
                        ConflictListTile(conflict: conflicts[index])));
  }
}
