import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/axis_day.dart';
import 'package:skeduler/screens/home/timetable_screen_components/axis_time.dart';
import 'package:skeduler/screens/home/timetable_screen_components/date_range.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/label_text_input.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);
    ValueNotifier<EditTimetable> editTTB =
        Provider.of<ValueNotifier<EditTimetable>>(context);

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    EditTimetable tempEditTTB = EditTimetable.copy(editTTB.value);

    return StreamBuilder<Object>(
        stream: dbService.getGroup(groupDocId.value),
        builder: (context, snapshot) {
          Group group = snapshot != null ? snapshot.data : null;

          return group == null
              ? Loading()
              : GestureDetector(
                  onTap: () => unfocus(),
                  child: Scaffold(
                    appBar: AppBar(
                      title: group.name == null
                          ? Text(
                              'Timetable Settings',
                              style: textStyleAppBarTitle,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  group.name,
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
                            if (_formKey.currentState.validate()) {
                              /// if new timetable or update previous timetable
                              if (editTTB.value == null ||
                                  editTTB.value.docId == tempEditTTB.docId) {
                                editTTB.value.updateTimetableSettings(
                                  docId: tempEditTTB.docId,
                                  startDate: tempEditTTB.startDate,
                                  endDate: tempEditTTB.endDate,
                                  axisDays: tempEditTTB.axisDays,
                                  axisTimes: tempEditTTB.axisTimes,
                                );

                                await dbService.updateGroupTimetable(
                                    groupDocId.value, editTTB.value);
                              } else if (editTTB.value != null &&
                                  editTTB.value.docId != null &&
                                  editTTB.value.docId.trim() != '' &&
                                  editTTB.value.docId != tempEditTTB.docId) {
                                /// Change ID by cloning old document with new ID
                                await dbService
                                    .updateGroupTimetableDocId(groupDocId.value,
                                        editTTB.value.docId, tempEditTTB.docId)
                                    .then((changed) async {
                                  if (changed) {
                                    /// Update document with new data
                                    editTTB.value.updateTimetableSettings(
                                      docId: tempEditTTB.docId,
                                      startDate: tempEditTTB.startDate,
                                      endDate: tempEditTTB.endDate,
                                      axisDays: tempEditTTB.axisDays,
                                      axisTimes: tempEditTTB.axisTimes,
                                    );

                                    await dbService.updateGroupTimetable(
                                        groupDocId.value, editTTB.value);
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
                              formKey: _formKey,
                              initialValue:
                                  editTTB != null && editTTB.value != null
                                      ? editTTB.value.docId
                                      : 'Timetable Name',
                              valSetText: (text) {
                                tempEditTTB.docId = text;
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
                            initialStartDate: editTTB.value.startDate,
                            initialEndDate: editTTB.value.endDate,
                            valSetStartDate: (startDate) {
                              tempEditTTB.startDate = startDate;
                            },
                            valSetEndDate: (endDate) {
                              tempEditTTB.endDate = endDate;
                            },
                          ),
                          SizedBox(height: 10.0),

                          AxisDay(
                            initialWeekdaysSelected: editTTB.value.axisDays,
                            valSetWeekdaysSelected:
                                (timetableWeekdaysSelected) {
                              tempEditTTB.axisDays = timetableWeekdaysSelected;
                            },
                          ),

                          AxisTime(
                            initialTimes: editTTB.value.axisTimes,
                            valSetTimes: (times) {
                              tempEditTTB.axisTimes = times;
                            },
                          ),
                          // AxisCustom(),
                        ],
                      ),
                    ),
                  ),
                );
        });
  }
}
