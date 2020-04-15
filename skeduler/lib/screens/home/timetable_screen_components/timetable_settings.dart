import 'package:flutter/material.dart';
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
    ValueNotifier<TempTimetable> tempTimetable =
        Provider.of<ValueNotifier<TempTimetable>>(context);

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    TempTimetable tempTimetableSub = TempTimetable();

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
                              'Timetable',
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
                                  'Timetable',
                                  style: textStyleBody,
                                )
                              ],
                            ),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              if (tempTimetable.value.docId ==
                                  tempTimetableSub.docId) {
                                tempTimetable.value.docId =
                                    tempTimetableSub.docId;
                                tempTimetable.value.startDate =
                                    tempTimetableSub.startDate;
                                tempTimetable.value.endDate =
                                    tempTimetableSub.endDate;
                                tempTimetable.value.axisDays =
                                    tempTimetableSub.axisDays;
                                tempTimetable.value.axisTimes =
                                    tempTimetableSub.axisTimes;

                                dbService.updateGroupTimetable(
                                    groupDocId.value, tempTimetable.value);
                              } else {
                                tempTimetable.value.docId =
                                    tempTimetableSub.docId;
                                tempTimetable.value.startDate =
                                    tempTimetableSub.startDate;
                                tempTimetable.value.endDate =
                                    tempTimetableSub.endDate;
                                tempTimetable.value.axisDays =
                                    tempTimetableSub.axisDays;
                                tempTimetable.value.axisTimes =
                                    tempTimetableSub.axisTimes;

                                dbService.updateGroupTimetable(
                                    groupDocId.value, tempTimetable.value);
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
                          LabelTextInput(
                            label: 'Name',
                            formKey: _formKey,
                            initialValue: tempTimetable != null &&
                                    tempTimetable.value != null
                                ? tempTimetable.value.docId
                                : 'Timetable Name',
                            valSetText: (text) {
                              tempTimetableSub.docId = text;
                            },
                            validator: (text) {
                              if (text == null || text.trim() == '') {
                                return 'Timetable name cannot be empty';
                              } else {
                                return null;
                              }
                            },
                          ),
                          SizedBox(height: 10.0),

                          DateRange(
                            initialStartDate: tempTimetable.value.startDate,
                            initialEndDate: tempTimetable.value.endDate,
                            valSetStartDate: (startDate) {
                              tempTimetableSub.startDate = startDate;
                            },
                            valSetEndDate: (endDate) {
                              tempTimetableSub.endDate = endDate;
                            },
                          ),
                          SizedBox(height: 10.0),

                          AxisDay(
                            initialWeekdaysSelected:
                                tempTimetable.value.axisDays,
                            valSetWeekdaysSelected:
                                (timetableWeekdaysSelected) {
                              tempTimetableSub.axisDays =
                                  timetableWeekdaysSelected;
                            },
                          ),

                          AxisTime(
                            initialTimes: tempTimetable.value.axisTimes,
                            valSetTimes: (times) {
                              tempTimetableSub.axisTimes = times;
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
