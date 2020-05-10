import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_display.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_switch_dialog.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/ui_settings.dart';

enum TimetableEditorOption { settings, switchAxis, addSubject, addDummy, save }

class TimetableEditor extends StatefulWidget {
  @override
  _TimetableEditorState createState() => _TimetableEditorState();
}

class _TimetableEditorState extends State<TimetableEditor> {
  TimetableEditMode _editMode = TimetableEditMode(editMode: true);

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);

    return Scaffold(
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
                  value: TimetableEditorOption.addSubject,
                  child: Text('Add subject'),
                ),
                PopupMenuItem(
                  value: TimetableEditorOption.addDummy,
                  child: Text('Add dummy'),
                ),
                PopupMenuItem(
                  value: TimetableEditorOption.save,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(height: 1.0),
                      SizedBox(height: 15),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.save,
                            color: Theme.of(context).brightness ==
                                    Brightness.light
                                ? Colors.black
                                : Colors.white,
                          ),
                          SizedBox(width: 10.0),
                          Text('Save'),
                        ],
                      ),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case TimetableEditorOption.settings:
                  ttbStatus.temp = EditTimetable.copy(ttbStatus.edit);
                  Navigator.of(context).pushNamed(
                    '/timetable/editor/settings',
                    arguments: RouteArgs(),
                  );
                  break;

                case TimetableEditorOption.switchAxis:
                  showDialog(
                      context: context,
                      builder: (context) {
                        return TimetableSwitchDialog(_editMode.editing);
                      });
                  break;

                case TimetableEditorOption.addSubject:
                  GlobalKey<FormState> formKey = GlobalKey<FormState>();
                  String newSubjectName;
                  String newSubjectNickname;

                  await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            'New subject',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Subject short form (optional)',
                                    hintStyle: TextStyle(
                                      fontSize: 15.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      newSubjectNickname = value.trim(),
                                  validator: (value) => null,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Subject full name',
                                    hintStyle: TextStyle(
                                      fontSize: 15.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      newSubjectName = value.trim(),
                                  validator: (value) =>
                                      value == null || value.trim() == ''
                                          ? 'Subject name cannot be empty'
                                          : null,
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('CANCEL'),
                              onPressed: () =>
                                  Navigator.of(context).maybePop(),
                            ),
                            FlatButton(
                              child: Text('SAVE'),
                              onPressed: () async {
                                if (formKey.currentState.validate()) {
                                  Navigator.of(context).maybePop();

                                  await dbService
                                      .updateGroupSubjects(
                                    groupStatus.group.docId,
                                    groupStatus.group.subjects,
                                  )
                                      .then((value) async {
                                    if (value) {
                                      groupStatus.group.subjects.add(Subject(
                                        name: newSubjectName,
                                        nickname: newSubjectNickname,
                                      ));

                                      String returnMsg =
                                          await dbService.addGroupSubject(
                                              groupStatus.group.docId,
                                              Subject(
                                                name: newSubjectName,
                                                nickname: newSubjectNickname,
                                              ));

                                      setState(() {
                                        groupStatus.hasChanges = false;
                                      });
                                      Fluttertoast.showToast(
                                        msg: returnMsg,
                                        toastLength: Toast.LENGTH_LONG,
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: 'Failed to update subjects',
                                        toastLength: Toast.LENGTH_LONG,
                                      );
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      });
                  break;

                case TimetableEditorOption.addDummy:
                  Navigator.of(context).pushNamed(
                    '/group/addDummy',
                    arguments: RouteArgs(),
                  );
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
              child: TimetableDisplay(editMode: _editMode),
            ),
    );
  }
}
