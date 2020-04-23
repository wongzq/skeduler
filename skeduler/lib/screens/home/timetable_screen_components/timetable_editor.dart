import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
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
    ValueNotifier<EditTimetable> editTtb =
        Provider.of<ValueNotifier<EditTimetable>>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            ),
            onPressed: () {
              editTtb.value = null;
              Navigator.of(context).pop();
            }),
        title: editTtb.value == null
            ? Text(
                'Timetable Editor',
                style: textStyleAppBarTitle,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    editTtb.value.docId ?? '',
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
              '/timetableSettings',
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
              .updateGroupTimetable(groupDocId.value, editTtb.value)
              .then((_) {
            Fluttertoast.showToast(
                msg: 'Successfully saved timetable',
                toastLength: Toast.LENGTH_LONG);
          }).catchError((_) {
            Fluttertoast.showToast(
                msg: 'Failed to save timetable',
                toastLength: Toast.LENGTH_LONG);
          });
        },
      ),
      body: editTtb.value != null
          ? TimetableDisplay(
              timetable: Timetable.fromEditTimetable(editTtb.value))
          : Container(),
    );
  }
}
