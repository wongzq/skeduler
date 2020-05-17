import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_display.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_switch_dialog.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/add_subject_dialog.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:skeduler/shared/widgets.dart';

enum TimetableEditorOption {
  switchAxis,
  addSubject,
  addDummy,
  clearData,
  settings,
  save,
}

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
          },
        ),
        title: AppBarTitle(
          title: ttbStatus.edit == null ? null : ttbStatus.edit.docId,
          alternateTitle: 'Timetable editor',
          subtitle: 'Timetable editor',
        ),
        actions: <Widget>[
          PopupMenuButton<TimetableEditorOption>(
            itemBuilder: (context) {
              return [
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
                  value: TimetableEditorOption.clearData,
                  child: Text('Clear data'),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: TimetableEditorOption.settings,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.settings,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                      SizedBox(width: 10.0),
                      Text('Settings'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: TimetableEditorOption.save,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.save,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                      SizedBox(width: 10.0),
                      Text('Save'),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case TimetableEditorOption.switchAxis:
                  showDialog(
                      context: context,
                      builder: (context) {
                        return TimetableSwitchDialog(_editMode.editing);
                      });
                  break;

                case TimetableEditorOption.addSubject:
                  GlobalKey<FormState> formKey = GlobalKey<FormState>();

                  setState(() async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return AddSubjectDialog(formKey: formKey);
                        });
                  });
                  break;

                case TimetableEditorOption.addDummy:
                  Navigator.of(context).pushNamed(
                    '/group/addDummy',
                    arguments: RouteArgs(),
                  );
                  break;

                case TimetableEditorOption.clearData:
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text('Clear all data from the timetable?'),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                              child: Text('CANCEL'),
                            ),
                            FlatButton(
                              onPressed: () {
                                setState(() {
                                  ttbStatus.edit.gridDataList.popAll();
                                });
                                Navigator.of(context).maybePop();
                              },
                              child: Text('CLEAR DATA'),
                            ),
                          ],
                        );
                      });
                  break;

                case TimetableEditorOption.settings:
                  ttbStatus.temp = EditTimetable.copy(ttbStatus.edit);
                  Navigator.of(context).pushNamed(
                    '/timetable/editor/settings',
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
      body: ttbStatus.edit == null || !ttbStatus.edit.isValid
          ? Container()
          : SafeArea(
              child: TimetableDisplay(editMode: _editMode),
            ),
    );
  }
}
