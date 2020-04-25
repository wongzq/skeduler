import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
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
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);
    ValueNotifier<EditTimetableStatus> editTtb =
        Provider.of<ValueNotifier<EditTimetableStatus>>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            ),
            onPressed: () {
              editTtb.value.perm = null;
              Navigator.of(context).pop();
            }),
        title: editTtb.value.perm == null
            ? Text(
                'Timetable Editor',
                style: textStyleAppBarTitle,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    editTtb.value.perm.docId ?? '',
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
            onPressed: () => Navigator.of(context).pushNamed(
              '/timetable/editor/settings',
            ),
          ),
        ],
      ),
      drawer: HomeDrawer(),
      floatingActionButton: FloatingActionButton(
        foregroundColor: getFABIconForegroundColor(context),
        backgroundColor: getFABIconBackgroundColor(context),
        child: Icon(Icons.save),
        onPressed: () async {
          await dbService
              .updateGroupTimetable(groupDocId.value, editTtb.value.perm)
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
      body: editTtb.value.perm != null && editTtb.value.perm.isValid()
          ? LayoutBuilder(
              builder: (context, constraints) {
                double memberSelectorHeight = 150;
                double timetableDisplayHeight =
                    constraints.maxHeight - memberSelectorHeight;

                return Container(
                  height: constraints.maxHeight,
                  child: ListView(
                    physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    children: <Widget>[
                      Container(
                        height: timetableDisplayHeight,
                        child: TimetableDisplay(
                          editMode: true,
                          timetable:
                              Timetable.fromEditTimetable(editTtb.value.perm),
                        ),
                      ),
                      Container(
                        height: memberSelectorHeight,
                        child: MemberSelector(),
                      ),
                    ],
                  ),
                );
              },
            )
          : Container(),
    );
  }
}
