import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/axis_custom.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/axis_day.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/axis_time.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/date_range.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/label_text_input.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/widgets.dart';

class TimetableSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    ttbStatus.temp = ttbStatus.temp != null && ttbStatus.temp.isValid
        ? ttbStatus.temp
        : ttbStatus.edit != null && ttbStatus.edit.isValid
            ? EditTimetable.copy(ttbStatus.edit)
            : EditTimetable();

    return GestureDetector(
      onTap: () => unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
              onPressed: () {
                ttbStatus.temp = EditTimetable();

                Navigator.of(context).maybePop();
              }),
          title: AppBarTitle(
            title: ttbStatus.temp.docId,
            alternateTitle: 'Timetable settings',
            subtitle: 'Timetable settings',
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'Timetable Settings Cancel',
              backgroundColor: Colors.red,
              child: Icon(Icons.close),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            SizedBox(width: 20.0),
            FloatingActionButton(
              heroTag: 'Timetable Settings Confirm',
              backgroundColor: Colors.green,
              child: Icon(Icons.check),
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  // check if new timetable (docId is null)
                  // check if update same timetable (docId is same)
                  if (ttbStatus.edit.docId == ttbStatus.temp.docId) {
                    ttbStatus.edit.updateTimetableSettings(
                      docId: ttbStatus.temp.docId,
                      startDate: ttbStatus.temp.startDate,
                      endDate: ttbStatus.temp.endDate,
                      axisDay: ttbStatus.temp.axisDay,
                      axisTime: ttbStatus.temp.axisTime,
                      axisCustom: ttbStatus.temp.axisCustom,
                    );
                    ttbStatus.update();
                    Navigator.of(context).maybePop();
                  }

                  // check if timetable docId changed
                  else if (ttbStatus.edit.docId != null &&
                      ttbStatus.edit.docId.trim() != '' &&
                      ttbStatus.edit.docId != ttbStatus.temp.docId) {
                    // change ID by cloning old document with new ID
                    OperationStatus status =
                        await dbService.updateGroupTimetableDocId(
                      groupStatus.group.docId,
                      ttbStatus.edit.metadata,
                      ttbStatus.temp.metadata,
                    );

                    if (status.completed) {
                      Fluttertoast.showToast(
                        msg: status.message,
                        toastLength: Toast.LENGTH_LONG,
                      );
                    }

                    if (status.success) {
                      // Update document with new data
                      ttbStatus.edit.updateTimetableSettings(
                        docId: ttbStatus.temp.docId,
                        startDate: ttbStatus.temp.startDate,
                        endDate: ttbStatus.temp.endDate,
                        axisDay: ttbStatus.temp.axisDay,
                        axisTime: ttbStatus.temp.axisTime,
                        axisCustom: ttbStatus.temp.axisCustom,
                      );
                      ttbStatus.update();
                      Navigator.of(context).maybePop();
                    }
                  }
                }
              },
            ),
          ],
        ),
        body: ListView(
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: <Widget>[
            // Timetable name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: LabelTextInput(
                label: 'Name',
                formKey: formKey,
                hintText: 'Timetable Name',
                initialValue: ttbStatus.temp.docId,
                valSetText: (text) {
                  ttbStatus.temp.docId = text;
                },
                validator: (text) {
                  if (text == null || text.trim() == '') {
                    return 'Timetable name cannot be empty';
                  } else {
                    return null;
                  }
                },
              ),
            ),
            SizedBox(height: 10.0),

            // Date range
            DateRange(
              initialStartDate: ttbStatus.temp.startDate,
              initialEndDate: ttbStatus.temp.endDate,
              valSetStartDate: (startDate) {
                ttbStatus.temp.startDate = startDate;
              },
              valSetEndDate: (endDate) {
                ttbStatus.temp.endDate = endDate;
              },
            ),
            SizedBox(height: 10.0),
            Divider(thickness: 1.0),

            // Axis Day
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: AxisDay(
                initialWeekdaysSelected: ttbStatus.temp.axisDay,
                valSetWeekdaysSelected: (timetableWeekdaysSelected) {
                  ttbStatus.temp.axisDay = timetableWeekdaysSelected;
                },
              ),
            ),
            Divider(thickness: 1.0),

            // Axis Time
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: AxisTime(
                initialTimes: ttbStatus.temp.axisTime,
                valSetTimes: (times) {
                  ttbStatus.temp.axisTime = times;
                },
              ),
            ),
            Divider(thickness: 1.0),

            // Axis Custom
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: AxisCustom(
                initialCustoms: ttbStatus.temp.axisCustom,
                valSetCustoms: (customVals) {
                  ttbStatus.temp.axisCustom = customVals;
                },
              ),
            ),
            Divider(thickness: 1.0),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: RaisedButton(
                color: Colors.red[300],
                highlightColor: Colors.red[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'DELETE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(
                              'Do you want to delete \'${ttbStatus.temp.docId}\' timetable?'),
                          actions: <Widget>[
                            // CANCEL button
                            FlatButton(
                              child: Text('CANCEL'),
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                            ),

                            // OK button
                            FlatButton(
                              child: Text(
                                'DELETE',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                await dbService.deleteGroupTimetable(
                                    groupStatus.group.docId,
                                    ttbStatus.edit.docId);
                                Navigator.of(context).maybePop();
                              },
                            ),
                          ],
                        );
                      });
                },
              ),
            ),
            SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }
}
