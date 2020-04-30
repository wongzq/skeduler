import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/screens/home/timetable_screen_components/member_selector.dart';
import 'package:skeduler/screens/home/timetable_screen_components/subject_selector.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_display.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_switch_dialog.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/ui_settings.dart';

enum TimetableEditorOption { settings, switchAxis, save }

class TimetableEditor extends StatefulWidget {
  @override
  _TimetableEditorState createState() => _TimetableEditorState();
}

class _TimetableEditorState extends State<TimetableEditor> {
  TimetableEditorBinVisible _binVisible = TimetableEditorBinVisible();
  Color _containerColor = Colors.black;
  int _animationDuration = 300;
  Curve _animationCurve = Curves.easeInCubic;

  TimetableEditMode _editMode = TimetableEditMode(editMode: true);

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    TimetableAxes axes = Provider.of<TimetableAxes>(context);

    return WillPopScope(
      onWillPop: () {
        axes.clearAxes();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              ),
              onPressed: () {
                ttbStatus.edit = null;
                Navigator.of(context).maybePop();
              }),
          title: ttbStatus.edit == null
              ? Text(
                  'Timetable Editor',
                  style: textStyleAppBarTitle,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ttbStatus.edit.docId ?? '',
                      style: textStyleAppBarTitle,
                    ),
                    Text(
                      'Timetable Editor',
                      style: textStyleBody,
                    )
                  ],
                ),
          actions: <Widget>[
            PopupMenuButton<TimetableEditorOption>(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: TimetableEditorOption.settings,
                    child: Text('Settings'),
                  ),
                  PopupMenuItem(
                    value: TimetableEditorOption.switchAxis,
                    child: Text('Switch axis'),
                  ),
                  PopupMenuItem(
                    value: TimetableEditorOption.save,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Divider(height: 1.0),
                        SizedBox(height: 15),
                        Text('Save'),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (value) async {
                switch (value) {
                  case TimetableEditorOption.settings:
                    ttbStatus.editTemp = EditTimetable.copy(ttbStatus.edit);
                    Navigator.of(context).pushNamed(
                      '/timetable/editor/settings',
                      arguments: RouteArgs(),
                    );
                    break;

                  case TimetableEditorOption.switchAxis:
                    showDialog(
                        context: context,
                        builder: (context) {
                          return TimetableSwitchDialog();
                        });
                    break;

                  case TimetableEditorOption.save:
                    await dbService
                        .updateGroupTimetable(
                            groupStatus.group.docId, ttbStatus.edit)
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
                    break;

                  default:
                    break;
                }
              },
            ),
          ],
        ),
        drawer: HomeDrawer(DrawerEnum.timetable),
        body: ttbStatus.edit == null || !ttbStatus.edit.isValid()
            ? Container()
            : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double selectorHeight = 80;
                    double timetableDisplayHeight =
                        constraints.maxHeight - selectorHeight * 2;

                    return ChangeNotifierProvider<
                        TimetableEditorBinVisible>.value(
                      value: _binVisible,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: constraints.maxHeight,
                            child: ListView(
                              children: <Widget>[
                                Container(
                                  height: timetableDisplayHeight,
                                  child: TimetableDisplay(
                                    editMode: _editMode,
                                  ),
                                ),
                                Container(
                                  height: selectorHeight,
                                  child: Stack(
                                    children: <Widget>[
                                      AbsorbPointer(
                                        absorbing: !_editMode.dragSubject,
                                        child: Center(
                                          child: SubjectSelector(
                                            activated: _editMode.dragSubject,
                                            additionalSpacing:
                                                constraints.maxWidth / 5,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        height: selectorHeight,
                                        width: constraints.maxWidth / 5,
                                        right: 0.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft,
                                              stops: [0.5, 0.8, 1],
                                              colors: [
                                                Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                Theme.of(context)
                                                    .scaffoldBackgroundColor
                                                    .withOpacity(0.8),
                                                Theme.of(context)
                                                    .scaffoldBackgroundColor
                                                    .withOpacity(0),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Switch(
                                              activeColor:
                                                  Theme.of(context).accentColor,
                                              value: _editMode.dragSubject,
                                              onChanged: (value) {
                                                setState(() => _editMode
                                                    .dragSubject = value);
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: selectorHeight,
                                  child: Stack(
                                    children: <Widget>[
                                      AbsorbPointer(
                                        absorbing: !_editMode.dragMember,
                                        child: Center(
                                          child: MemberSelector(
                                            activated: _editMode.dragMember,
                                            additionalSpacing:
                                                constraints.maxWidth / 5,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        height: selectorHeight,
                                        width: constraints.maxWidth / 5,
                                        right: 0.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft,
                                              stops: [0.5, 0.8, 1],
                                              colors: [
                                                Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                Theme.of(context)
                                                    .scaffoldBackgroundColor
                                                    .withOpacity(0.8),
                                                Theme.of(context)
                                                    .scaffoldBackgroundColor
                                                    .withOpacity(0),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Switch(
                                              activeColor:
                                                  Theme.of(context).accentColor,
                                              value: _editMode.dragMember,
                                              onChanged: (value) {
                                                setState(() => _editMode
                                                    .dragMember = value);
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Consumer<TimetableEditorBinVisible>(
                            builder: (context, binVisible, _) {
                              return AnimatedPositioned(
                                duration:
                                    Duration(milliseconds: _animationDuration),
                                curve: _animationCurve,
                                top: binVisible.visible
                                    ? timetableDisplayHeight
                                    : constraints.maxHeight,
                                child: DragTarget<TimetableDragData>(
                                  onWillAccept: (val) {
                                    _containerColor = Colors.red;
                                    return true;
                                  },
                                  onAccept: (_) =>
                                      _containerColor = Colors.black,
                                  onLeave: (_) =>
                                      _containerColor = Colors.black,
                                  builder: (_, __, ___) {
                                    return AnimatedContainer(
                                      duration: Duration(
                                          milliseconds: _animationDuration),
                                      curve: _animationCurve,
                                      alignment: Alignment.bottomCenter,
                                      height: binVisible.visible
                                          ? selectorHeight * 2
                                          : 0,
                                      width: constraints.maxWidth,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            _containerColor,
                                            Colors.transparent
                                          ],
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: AnimatedCrossFade(
                                          duration: Duration(
                                              milliseconds: _animationDuration),
                                          firstCurve: _animationCurve,
                                          secondCurve: _animationCurve,
                                          crossFadeState: binVisible.visible
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
