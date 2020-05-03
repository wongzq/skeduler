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
import 'package:skeduler/shared/ui_settings.dart';

enum TimetableEditorOption { settings, switchAxis, save }

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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.save),
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
                child: TimetableDisplay(editMode: _editMode),
              ),
      ),
    );
  }
}
