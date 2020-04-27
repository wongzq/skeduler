import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/screens/home/timetable_screen_components/member_selector.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_display.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableEditor extends StatefulWidget {
  @override
  _TimetableEditorState createState() => _TimetableEditorState();
}

class _TimetableEditorState extends State<TimetableEditor> {
  BinVisibleBool binVisible = BinVisibleBool();
  Color containerColor = Colors.black;
  int animationDuration = 300;
  Curve animationCurve = Curves.easeInCubic;

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<Group> group = Provider.of<ValueNotifier<Group>>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    TimetableAxes _axes = Provider.of<TimetableAxes>(context);

    return WillPopScope(
      onWillPop: () {
        _axes.clearAxes();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              ),
              onPressed: () {
                ttbStatus.perm = null;
                Navigator.of(context).maybePop();
              }),
          title: ttbStatus.perm == null
              ? Text(
                  'Timetable Editor',
                  style: textStyleAppBarTitle,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ttbStatus.perm.docId ?? '',
                      style: textStyleAppBarTitle,
                    ),
                    Text(
                      'Timetable Editor',
                      style: textStyleBody,
                    )
                  ],
                ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                ttbStatus.temp = EditTimetable.copy(ttbStatus.perm);
                Navigator.of(context).pushNamed(
                  '/timetable/editor/settings',
                  arguments: RouteArgs(),
                );
              },
            ),
          ],
        ),
        drawer: HomeDrawer(DrawerEnum.timetable),
        floatingActionButton: FloatingActionButton(
          foregroundColor: getFABIconForegroundColor(context),
          backgroundColor: getFABIconBackgroundColor(context),
          child: Icon(Icons.save),
          onPressed: () async {
            await dbService
                .updateGroupTimetable(group.value.docId, ttbStatus.perm)
                .then((_) {
              Fluttertoast.showToast(
                msg: 'Successfully saved timetable',
                toastLength: Toast.LENGTH_LONG,
              );
            }).catchError((_) {
              Fluttertoast.showToast(
                msg: 'Failed to save timetable',
                toastLength: Toast.LENGTH_LONG,
              );
            });
          },
        ),
        body: ttbStatus.perm == null || !ttbStatus.perm.isValid()
            ? Container()
            : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double memberSelectorHeight = 150;
                    double timetableDisplayHeight =
                        constraints.maxHeight - memberSelectorHeight;

                    return ChangeNotifierProvider<BinVisibleBool>(
                      create: (_) => BinVisibleBool(),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: constraints.maxHeight,
                            child: ListView(
                              children: <Widget>[
                                Container(
                                  height: timetableDisplayHeight,
                                  child: TimetableDisplay(
                                    editMode: true,
                                  ),
                                ),
                                Container(
                                  height: memberSelectorHeight,
                                  child: MemberSelector(),
                                ),
                              ],
                            ),
                          ),
                          Consumer<BinVisibleBool>(
                            builder: (_, binVisible, __) {
                              return AnimatedPositioned(
                                duration:
                                    Duration(milliseconds: animationDuration),
                                curve: animationCurve,
                                top: binVisible.value
                                    ? timetableDisplayHeight
                                    : constraints.maxHeight,
                                child: DragTarget<Member>(
                                  onWillAccept: (val) {
                                    containerColor = Colors.red;
                                    return true;
                                  },
                                  onAccept: (_) =>
                                      containerColor = Colors.black,
                                  onLeave: (_) => containerColor = Colors.black,
                                  builder: (_, __, ___) {
                                    return AnimatedContainer(
                                      duration: Duration(
                                          milliseconds: animationDuration),
                                      curve: animationCurve,
                                      alignment: Alignment.bottomCenter,
                                      height: binVisible.value
                                          ? memberSelectorHeight
                                          : 0,
                                      width: constraints.maxWidth,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            containerColor,
                                            Colors.transparent
                                          ],
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: AnimatedCrossFade(
                                          duration: Duration(
                                              milliseconds: animationDuration),
                                          firstCurve: animationCurve,
                                          secondCurve: animationCurve,
                                          crossFadeState: binVisible.value
                                              ? CrossFadeState.showFirst
                                              : CrossFadeState.showSecond,
                                          firstChild: Icon(
                                            Icons.delete,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                          secondChild: Icon(
                                            null,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
