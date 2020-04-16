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
    ValueNotifier<TempTimetable> tempTTB =
        Provider.of<ValueNotifier<TempTimetable>>(context);

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    TempTimetable tempTTBSub = TempTimetable(tempTTB: tempTTB.value);

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
                              print(tempTTB.value);
                              print(tempTTB.value.docId);

                              /// if new timetable or update previous timetable
                              if (tempTTB.value == null ||
                                  tempTTB.value.docId == tempTTBSub.docId) {
                                tempTTB.value.docId = tempTTBSub.docId;
                                tempTTB.value.startDate = tempTTBSub.startDate;
                                tempTTB.value.endDate = tempTTBSub.endDate;
                                tempTTB.value.axisDays = tempTTBSub.axisDays;
                                tempTTB.value.axisTimes = tempTTBSub.axisTimes;

                                await dbService.updateGroupTimetable(
                                    groupDocId.value, tempTTB.value);
                              } else if (tempTTB.value != null &&
                                  tempTTB.value.docId != null &&
                                  tempTTB.value.docId.trim() != '' &&
                                  tempTTB.value.docId != tempTTBSub.docId) {
                                print('here');

                                /// Change ID by cloning old document with new ID
                                await dbService
                                    .updateGroupTimetableDocId(groupDocId.value,
                                        tempTTB.value.docId, tempTTBSub.docId)
                                    .then((changed) async {
                                  if (changed) {
                                    /// Update document with new data
                                    tempTTB.value.docId = tempTTBSub.docId;
                                    tempTTB.value.startDate =
                                        tempTTBSub.startDate;
                                    tempTTB.value.endDate = tempTTBSub.endDate;
                                    tempTTB.value.axisDays =
                                        tempTTBSub.axisDays;
                                    tempTTB.value.axisTimes =
                                        tempTTBSub.axisTimes;

                                    await dbService.updateGroupTimetable(
                                        groupDocId.value, tempTTB.value);
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
                                  tempTTB != null && tempTTB.value != null
                                      ? tempTTB.value.docId
                                      : 'Timetable Name',
                              valSetText: (text) {
                                tempTTBSub.docId = text;
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
                            initialStartDate: tempTTB.value.startDate,
                            initialEndDate: tempTTB.value.endDate,
                            valSetStartDate: (startDate) {
                              tempTTBSub.startDate = startDate;
                            },
                            valSetEndDate: (endDate) {
                              tempTTBSub.endDate = endDate;
                            },
                          ),
                          SizedBox(height: 10.0),

                          AxisDay(
                            initialWeekdaysSelected: tempTTB.value.axisDays,
                            valSetWeekdaysSelected:
                                (timetableWeekdaysSelected) {
                              tempTTBSub.axisDays = timetableWeekdaysSelected;
                            },
                          ),

                          AxisTime(
                            initialTimes: tempTTB.value.axisTimes,
                            valSetTimes: (times) {
                              tempTTBSub.axisTimes = times;
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
