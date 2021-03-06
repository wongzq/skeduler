import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/navigation/route_arguments.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/auxiliary/time.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/navigation/home_drawer.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_display.dart';
import 'package:skeduler/shared/simple_widgets.dart';
import 'package:skeduler/shared/widgets/loading.dart';

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  bool _viewTodayTtb;
  TimetableEditMode _editMode;

  @override
  void initState() {
    _viewTodayTtb = true;
    _editMode = TimetableEditMode(editMode: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    bool isPlaceholder = true;

    TimetableMetadata timetableMetaForToday = groupStatus.group == null
        ? null
        : groupStatus.group.timetableMetadatas.firstWhere(
            (metadata) =>
                metadata.startDate.millisecondsSinceEpoch <=
                    DateTime.now().millisecondsSinceEpoch &&
                metadata.endDate
                        .toDate()
                        .add(Duration(days: 1))
                        .millisecondsSinceEpoch >=
                    DateTime.now().millisecondsSinceEpoch,
            orElse: () => null);

    String timetableIdForToday =
        groupStatus.group == null || timetableMetaForToday == null
            ? ''
            : timetableMetaForToday.docId;

    Timetable timetable =
        timetableIdForToday == null || groupStatus.timetables == null
            ? null
            : groupStatus.timetables.firstWhere(
                (element) => element.docId == timetableIdForToday,
                orElse: () => null);

    // if timetable is found
    if (timetable != null && timetable.isValid) {
      isPlaceholder = false;

      // if view today's timetable
      if (_viewTodayTtb) {
        if (ttbStatus.curr == null || ttbStatus.curr.docId == timetable.docId) {
          ttbStatus.curr = timetable;
        } else {
          ttbStatus.curr = null;
          ttbStatus.curr = timetable;
        }
      }
    } else {
      isPlaceholder = true;
      ttbStatus.curr = null;
    }

    return groupStatus.group == null
        ? Stack(children: <Widget>[
            Scaffold(
                appBar: AppBar(title: AppBarTitle(title: 'Timetable')),
                drawer: HomeDrawer(DrawerEnum.timetables)),
            Loading()
          ])
        : Scaffold(
            appBar: AppBar(
                elevation: 0.0,
                title: AppBarTitle(
                    title: groupStatus.group.name == null
                        ? null
                        : groupStatus.group.name,
                    alternateTitle: 'Timetable',
                    subtitle: groupStatus.group.name == null ||
                            timetable == null ||
                            !timetable.isValid ||
                            ttbStatus.curr == null
                        ? 'Timetable'
                        : 'Timetable: ${ttbStatus.curr.docId}'),
                actions: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: PopupMenuButton(
                          child: Icon(Icons.more_vert),
                          itemBuilder: (BuildContext context) {
                            List<PopupMenuEntry> popupOptions = [];

                            // Add timetables to options
                            groupStatus.group.timetableMetadatas
                                .forEach((timetableMetadata) {
                              popupOptions.add(PopupMenuItem(
                                  value: timetableMetadata.docId,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(timetableMetadata.docId),
                                        Text(
                                            DateFormat('dd MMM').format(
                                                    timetableMetadata.startDate
                                                        .toDate()) +
                                                ' - ' +
                                                DateFormat('dd MMM').format(
                                                    timetableMetadata.endDate
                                                        .toDate()),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.0))
                                      ])));
                            });

                            // Add 'add timetable' button to options
                            if (groupStatus.me.role == MemberRole.owner ||
                                groupStatus.me.role == MemberRole.admin) {
                              popupOptions.add(PopupMenuItem(
                                  value: 0,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Visibility(
                                          visible: groupStatus.group
                                              .timetableMetadatas.isNotEmpty,
                                          child: Divider(thickness: 1.0),
                                        ),
                                        Row(children: <Widget>[
                                          Icon(Icons.add,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.white),
                                          SizedBox(width: 10.0),
                                          Text('Add timetable')
                                        ])
                                      ])));
                            } else if (groupStatus.me.role ==
                                MemberRole.member) {
                              popupOptions.add(PopupMenuItem(
                                  value: 0,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Visibility(
                                            visible: groupStatus.group
                                                .timetableMetadatas.isNotEmpty,
                                            child: Divider(thickness: 1.0)),
                                        Row(children: <Widget>[
                                          Icon(Icons.today,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.white),
                                          SizedBox(width: 10.0),
                                          Text('Today\'s timetable')
                                        ])
                                      ])));
                            }
                            return popupOptions;
                          },
                          onSelected: (value) async {
                            if (value == 0) {
                              if (groupStatus.me.role == MemberRole.owner ||
                                  groupStatus.me.role == MemberRole.admin) {
                                ttbStatus.temp = EditTimetable(groups: [
                                  TimetableGroup(
                                      axisDay: List.generate(
                                          5, (index) => Weekday.values[index]),
                                      axisTime: [
                                        Time(
                                            startTime:
                                                DateTime(DateTime.now().year)
                                                    .add(Duration(
                                                        hours: DateTime.now()
                                                                .hour +
                                                            0)),
                                            endTime: DateTime(
                                                    DateTime.now().year)
                                                .add(Duration(
                                                    hours: DateTime.now().hour +
                                                        1))),
                                        Time(
                                            startTime:
                                                DateTime(DateTime.now().year)
                                                    .add(Duration(
                                                        hours: DateTime.now()
                                                                .hour +
                                                            1)),
                                            endTime: DateTime(
                                                    DateTime.now().year)
                                                .add(Duration(
                                                    hours: DateTime.now().hour +
                                                        2)))
                                      ],
                                      axisCustom: [
                                        'A',
                                        'B'
                                      ])
                                ]);
                                Navigator.of(context).pushNamed(
                                  '/timetables/newTimetable',
                                  arguments: RouteArgs(),
                                );
                              } else if (groupStatus.me.role ==
                                  MemberRole.member) {
                                setState(() {
                                  _viewTodayTtb = true;
                                  ttbStatus.curr = null;
                                });
                              }
                            } else if (value is String) {
                              if (groupStatus.me.role == MemberRole.owner ||
                                  groupStatus.me.role == MemberRole.admin) {
                                ttbStatus.edit = EditTimetable.fromTimetable(
                                    groupStatus.timetables.firstWhere(
                                        (element) => element.docId == value,
                                        orElse: () => null));
                                Navigator.of(context).pushNamed(
                                    '/timetables/editor',
                                    arguments: RouteArgs());
                              } else if (groupStatus.me.role ==
                                  MemberRole.member) {
                                Timetable timetable = groupStatus.timetables
                                    .firstWhere(
                                        (element) => element.docId == value,
                                        orElse: () => null);

                                setState(() {
                                  _viewTodayTtb = false;
                                  ttbStatus.curr = null;
                                  ttbStatus.curr = timetable;
                                });
                              }
                            }
                          }))
                ]),
            drawer: HomeDrawer(DrawerEnum.timetables),
            body: groupStatus.me == null
                ? Container()
                : isPlaceholder
                    ? EmptyPlaceholder(
                        iconData: Icons.table_chart,
                        text: 'No timetable for today')
                    : TimetableDisplay(editMode: _editMode));
  }
}
