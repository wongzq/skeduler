import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
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
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);
    ValueNotifier<EditTimetable> editTtb =
        Provider.of<ValueNotifier<EditTimetable>>(context);

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    EditTimetable tempEditTtb = editTtb.value != null
        ? EditTimetable.copy(editTtb.value)
        : EditTimetable();

    return GestureDetector(
      onTap: () => unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: editTtb.value.docId == null
              ? Text(
                  'Timetable Settings',
                  style: textStyleAppBarTitle,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      editTtb.value.docId,
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
                  if (editTtb.value.docId == null ||
                      editTtb.value.docId == tempEditTtb.docId) {
                    editTtb.value.updateTimetableSettings(
                      docId: tempEditTtb.docId,
                      startDate: tempEditTtb.startDate,
                      endDate: tempEditTtb.endDate,
                      axisDays: tempEditTtb.axisDays,
                      axisTimes: tempEditTtb.axisTimes,
                    );

                    Navigator.of(context).pop();
                  }

                  /// check if timetable docId changed
                  else if (editTtb.value.docId != null &&
                      editTtb.value.docId.trim() != '' &&
                      editTtb.value.docId != tempEditTtb.docId) {
                    /// change ID by cloning old document with new ID
                    await dbService
                        .updateGroupTimetableDocId(
                      groupDocId.value,
                      editTtb.value.metadata,
                      tempEditTtb.metadata,
                    )
                        .then((changed) async {
                      if (changed) {
                        /// Update document with new data
                        editTtb.value.updateTimetableSettings(
                          docId: tempEditTtb.docId,
                          startDate: tempEditTtb.startDate,
                          endDate: tempEditTtb.endDate,
                          axisDays: tempEditTtb.axisDays,
                          axisTimes: tempEditTtb.axisTimes,
                        );
                        Navigator.of(context).pop();
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
        body: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ListView(
            physics: BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: LabelTextInput(
                  label: 'Name',
                  formKey: formKey,
                  hintText: 'Timetable Name',
                  initialValue: editTtb.value.docId,
                  valSetText: (text) {
                    tempEditTtb.docId = text;
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

              DateRange(
                initialStartDate: editTtb.value.startDate,
                initialEndDate: editTtb.value.endDate,
                valSetStartDate: (startDate) {
                  tempEditTtb.startDate = startDate;
                },
                valSetEndDate: (endDate) {
                  tempEditTtb.endDate = endDate;
                },
              ),

              SizedBox(height: 10.0),

              AxisDay(
                initialWeekdaysSelected: editTtb.value.axisDays,
                valSetWeekdaysSelected: (timetableWeekdaysSelected) {
                  tempEditTtb.axisDays = timetableWeekdaysSelected;
                },
              ),

              AxisTime(
                initialTimes: editTtb.value.axisTimes,
                valSetTimes: (times) {
                  tempEditTtb.axisTimes = times;
                },
              ),
              // AxisCustom(),
            ],
          ),
        ),
      ),
    );
  }
}
