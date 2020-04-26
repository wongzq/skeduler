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
    ValueNotifier<Group> group = Provider.of<ValueNotifier<Group>>(context);
    ValueNotifier<EditTimetableStatus> editTtb =
        Provider.of<ValueNotifier<EditTimetableStatus>>(context);

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    editTtb.value.temp =
        editTtb.value.temp != null && editTtb.value.temp.isValid()
            ? editTtb.value.temp
            : editTtb.value.perm != null && editTtb.value.perm.isValid()
                ? EditTimetable.copy(editTtb.value.perm)
                : EditTimetable();

    return GestureDetector(
      onTap: () => unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
              onPressed: () {
                editTtb.value.temp = EditTimetable();

                Navigator.of(context).maybePop();
              }),
          title: editTtb.value.temp.docId == null
              ? Text(
                  'Timetable Settings',
                  style: textStyleAppBarTitle,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      editTtb.value.temp.docId,
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
                  /// check if new timetable (docId is null)
                  /// check if update same timetable (docId is same)
                  if (editTtb.value.perm.docId == null ||
                      editTtb.value.perm.docId == editTtb.value.temp.docId) {
                    editTtb.value.perm.updateTimetableSettings(
                      docId: editTtb.value.temp.docId,
                      startDate: editTtb.value.temp.startDate,
                      endDate: editTtb.value.temp.endDate,
                      axisDay: editTtb.value.temp.axisDay,
                      axisTime: editTtb.value.temp.axisTime,
                      axisCustom: editTtb.value.temp.axisCustom,
                    );

                    Navigator.of(context).maybePop();
                  }

                  /// check if timetable docId changed
                  else if (editTtb.value.perm.docId != null &&
                      editTtb.value.perm.docId.trim() != '' &&
                      editTtb.value.perm.docId != editTtb.value.temp.docId) {
                    /// change ID by cloning old document with new ID
                    await dbService
                        .updateGroupTimetableDocId(
                      group.value.docId,
                      editTtb.value.perm.metadata,
                      editTtb.value.temp.metadata,
                    )
                        .then((changed) async {
                      if (changed) {
                        /// Update document with new data
                        editTtb.value.perm.updateTimetableSettings(
                          docId: editTtb.value.temp.docId,
                          startDate: editTtb.value.temp.startDate,
                          endDate: editTtb.value.temp.endDate,
                          axisDay: editTtb.value.temp.axisDay,
                          axisTime: editTtb.value.temp.axisTime,
                          axisCustom: editTtb.value.temp.axisCustom,
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
            /// Timetable name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: LabelTextInput(
                label: 'Name',
                formKey: formKey,
                hintText: 'Timetable Name',
                initialValue: editTtb.value.temp.docId,
                valSetText: (text) {
                  editTtb.value.temp.docId = text;
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

            /// Date range
            DateRange(
              initialStartDate: editTtb.value.temp.startDate,
              initialEndDate: editTtb.value.temp.endDate,
              valSetStartDate: (startDate) {
                editTtb.value.temp.startDate = startDate;
              },
              valSetEndDate: (endDate) {
                editTtb.value.temp.endDate = endDate;
              },
            ),
            SizedBox(height: 10.0),
            Divider(thickness: 1.0),

            /// Axis Day
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: AxisDay(
                initialWeekdaysSelected: editTtb.value.temp.axisDay,
                valSetWeekdaysSelected: (timetableWeekdaysSelected) {
                  editTtb.value.temp.axisDay = timetableWeekdaysSelected;
                },
              ),
            ),
            Divider(thickness: 1.0),

            /// Axis Time
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: AxisTime(
                initialTimes: editTtb.value.temp.axisTime,
                valSetTimes: (times) {
                  editTtb.value.temp.axisTime = times;
                },
              ),
            ),
            Divider(thickness: 1.0),

            /// Axis Custom
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: AxisCustom(
                initialCustoms: editTtb.value.temp.axisCustom,
                valSetCustoms: (customVals) {
                  editTtb.value.temp.axisCustom = customVals;
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
                              'Do you want to delete \'${editTtb.value.temp.docId}\' timetable?'),
                          actions: <Widget>[
                            /// CANCEL button
                            FlatButton(
                              child: Text('CANCEL'),
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                            ),

                            /// OK button
                            FlatButton(
                              child: Text(
                                'DELETE',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                await dbService.deleteGroupTimetable(
                                    group.value.docId,
                                    editTtb.value.perm.docId);
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
