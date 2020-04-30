import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/axis_custom.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/axis_day.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/axis_time.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/date_range.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/label_text_input.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    ttbStatus.editTemp = ttbStatus.editTemp != null && ttbStatus.editTemp.isValid()
        ? ttbStatus.editTemp
        : ttbStatus.edit != null && ttbStatus.edit.isValid()
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
                ttbStatus.editTemp = EditTimetable();

                Navigator.of(context).maybePop();
              }),
          title: ttbStatus.editTemp.docId == null
              ? Text(
                  'Timetable Settings',
                  style: textStyleAppBarTitle,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ttbStatus.editTemp.docId,
                      style: textStyleAppBarTitle,
                    ),
                    Text(
                      'Timetable Settings',
                      style: textStyleBody,
                    )
                  ],
                ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  // check if new timetable (docId is null)
                  // check if update same timetable (docId is same)
                  if (ttbStatus.edit.docId == null ||
                      ttbStatus.edit.docId == ttbStatus.editTemp.docId) {
                    ttbStatus.edit.updateTimetableSettings(
                      docId: ttbStatus.editTemp.docId,
                      startDate: ttbStatus.editTemp.startDate,
                      endDate: ttbStatus.editTemp.endDate,
                      axisDay: ttbStatus.editTemp.axisDay,
                      axisTime: ttbStatus.editTemp.axisTime,
                      axisCustom: ttbStatus.editTemp.axisCustom,
                    );

                    Navigator.of(context).maybePop();
                  }

                  // check if timetable docId changed
                  else if (ttbStatus.edit.docId != null &&
                      ttbStatus.edit.docId.trim() != '' &&
                      ttbStatus.edit.docId != ttbStatus.editTemp.docId) {
                    // change ID by cloning old document with new ID
                    await dbService
                        .updateGroupTimetableDocId(
                      groupStatus.group.docId,
                      ttbStatus.edit.metadata,
                      ttbStatus.editTemp.metadata,
                    )
                        .then((changed) async {
                      if (changed) {
                        // Update document with new data
                        ttbStatus.edit.updateTimetableSettings(
                          docId: ttbStatus.editTemp.docId,
                          startDate: ttbStatus.editTemp.startDate,
                          endDate: ttbStatus.editTemp.endDate,
                          axisDay: ttbStatus.editTemp.axisDay,
                          axisTime: ttbStatus.editTemp.axisTime,
                          axisCustom: ttbStatus.editTemp.axisCustom,
                        );
                        Navigator.of(context).maybePop();
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Timetable ID already exists',
                          toastLength: Toast.LENGTH_LONG,
                        );
                      }
                    });
                  }
                }
              },
            )
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
                initialValue: ttbStatus.editTemp.docId,
                valSetText: (text) {
                  ttbStatus.editTemp.docId = text;
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
              initialStartDate: ttbStatus.editTemp.startDate,
              initialEndDate: ttbStatus.editTemp.endDate,
              valSetStartDate: (startDate) {
                ttbStatus.editTemp.startDate = startDate;
              },
              valSetEndDate: (endDate) {
                ttbStatus.editTemp.endDate = endDate;
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
                initialWeekdaysSelected: ttbStatus.editTemp.axisDay,
                valSetWeekdaysSelected: (timetableWeekdaysSelected) {
                  ttbStatus.editTemp.axisDay = timetableWeekdaysSelected;
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
                initialTimes: ttbStatus.editTemp.axisTime,
                valSetTimes: (times) {
                  ttbStatus.editTemp.axisTime = times;
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
                initialCustoms: ttbStatus.editTemp.axisCustom,
                valSetCustoms: (customVals) {
                  ttbStatus.editTemp.axisCustom = customVals;
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
                              'Do you want to delete \'${ttbStatus.editTemp.docId}\' timetable?'),
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
                                    groupStatus.group.docId, ttbStatus.edit.docId);
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
