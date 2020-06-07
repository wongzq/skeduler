import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/conflict.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
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
  OriginTheme _originTheme;
  GroupStatus _groupStatus;

  bool _showIgnored = false;
  ConflictSort _sortBy = ConflictSort.date;

  List<Widget> _generateActions() {
    return [
      PopupMenuButton(
        icon: Icon(Icons.sort),
        itemBuilder: (context) => [
          PopupMenuItem(value: ConflictSort.date, child: Text('Sort by date')),
          PopupMenuItem(
              value: ConflictSort.member, child: Text('Sort by member')),
          PopupMenuItem(
              child: StatefulBuilder(
                  builder: (context, popupSetState) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => popupSetState(
                          () => setState(() => _showIgnored = !_showIgnored)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Show ignored'),
                            Checkbox(
                                activeColor: _originTheme.primaryColor,
                                value: _showIgnored,
                                onChanged: (_) {
                                  popupSetState(() {
                                    setState(() {
                                      _showIgnored = !_showIgnored;
                                    });
                                  });
                                })
                          ]))))
        ],
        onSelected: (value) =>
            setState(() => _sortBy = value ?? ConflictSort.date),
      )
    ];
  }

  List<Conflict> _generateConflicts() {
    List<Conflict> conflicts = _groupStatus.group.conflicts;

    conflicts = _showIgnored
        ? conflicts
        : conflicts.where((element) => !element.gridData.ignore).toList();

    if (_sortBy == ConflictSort.date) {
      conflicts.sort((a, b) {
        int result = a.gridData.ignore == true && b.gridData.ignore == false
            ? 1
            : a.gridData.ignore == false && b.gridData.ignore == true
                ? -1
                : a.gridData.ignore == b.gridData.ignore ? 0 : null;

        if (result != 0)
          return result;
        else
          return a.conflictDates.length == 0 && b.conflictDates.length == 0
              ? 0
              : a.conflictDates.length == 0 && b.conflictDates.length > 0
                  ? -1
                  : a.conflictDates.length > 0 && b.conflictDates.length == 0
                      ? 1
                      : a.conflictDates.first.compareTo(b.conflictDates.first);
      });
    } else if (_sortBy == ConflictSort.member) {
      conflicts.sort((a, b) {
        int result = a.gridData.ignore == true && b.gridData.ignore == false
            ? 1
            : a.gridData.ignore == false && b.gridData.ignore == true
                ? -1
                : a.gridData.ignore == b.gridData.ignore ? 0 : null;

        if (result != 0)
          return result;
        else
          return a.gridData.dragData.member.docId
              .compareTo(b.gridData.dragData.member.docId);
      });
    }

    return conflicts;
  }

  @override
  Widget build(BuildContext context) {
    _groupStatus = Provider.of<GroupStatus>(context);
    _originTheme = Provider.of<OriginTheme>(context);

    List<Conflict> conflicts = _generateConflicts();

    return _groupStatus.group == null
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
                    title: _groupStatus.group.name,
                    alternateTitle: 'Admin Panel',
                    subtitle: 'Admin Panel'),
                actions: _generateActions()),
            drawer: HomeDrawer(DrawerEnum.group),
            floatingActionButton: _groupStatus.me != null
                ? _groupStatus.me.role == MemberRole.owner
                    ? GroupScreenOptionsOwner()
                    : _groupStatus.me.role == MemberRole.admin
                        ? GroupScreenOptionsAdmin()
                        : null
                : null,
            body: _groupStatus.group.conflicts.length == 0
                ? EmptyPlaceholder(
                    iconData: Icons.schedule, text: 'No schedule conflicts')
                : ListView.builder(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: conflicts.length,
                    itemBuilder: (context, index) =>
                        ConflictListTile(conflict: conflicts[index])),
          );
  }
}
