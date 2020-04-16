import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
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
    ValueNotifier<TempTimetable> tempTTB =
        Provider.of<ValueNotifier<TempTimetable>>(context);

    return tempTTB.value == null
        ? Container()
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: tempTTB.value.docId == null
                  ? Text(
                      'Timetable Editor',
                      style: textStyleAppBarTitle,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          tempTTB.value.docId,
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
            body: Stack(
              children: <Widget>[
                Container(),
                Visibility(
                  visible: true,
                  child: Positioned(
                    right: 20.0,
                    bottom: 20.0,
                    child: FloatingActionButton(
                      foregroundColor: getFABIconForegroundColor(context),
                      backgroundColor: getFABIconBackgroundColor(context),
                      child: Icon(Icons.save),
                      onPressed: () {
                        dbService.updateGroupTimetable(
                          groupDocId.value,
                          tempTTB.value,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
