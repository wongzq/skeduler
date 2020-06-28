import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_settings/axis_custom.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_settings/axis_day.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_settings/axis_time.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_settings/timetable_date_range.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_settings/timetable_group_selector.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/widgets/label_text_input.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class TimetableSettings extends StatefulWidget {
  @override
  _TimetableSettingsState createState() => _TimetableSettingsState();
}

class _TimetableSettingsState extends State<TimetableSettings> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey _key1 = GlobalKey();
  GlobalKey _key2 = GlobalKey();
  int _startDateWeek;
  int _endDateWeek;

  String _weekAsDocId() {
    return _startDateWeek == _endDateWeek
        ? 'Week $_startDateWeek'
        : 'Week $_startDateWeek - $_endDateWeek';
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);

    ttbStatus.temp = ttbStatus.temp != null && ttbStatus.temp.isValid
        ? ttbStatus.temp
        : ttbStatus.edit != null && ttbStatus.edit.isValid
            ? EditTimetable.from(ttbStatus.edit)
            : EditTimetable();

    int index = ttbStatus.tempGroupIndex;

    DateTime defaultDate = groupStatus.group.timetableMetadatas.isEmpty
        ? DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day)
        : groupStatus.group.timetableMetadatas.last.endDate
            .toDate()
            .add(Duration(days: 1));

    _startDateWeek = ttbStatus.temp.startDate == null
        ? getWeekOfYear(defaultDate)
        : getWeekOfYear(ttbStatus.temp.startDate);

    _endDateWeek = ttbStatus.temp.endDate == null
        ? getWeekOfYear(defaultDate)
        : getWeekOfYear(ttbStatus.temp.endDate);

    return GestureDetector(
        onTap: () => unfocus(),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Platform.isIOS
                        ? Icons.arrow_back_ios
                        : Icons.arrow_back),
                    onPressed: () {
                      ttbStatus.temp = EditTimetable();
                      Navigator.of(context).maybePop();
                    }),
                title: AppBarTitle(
                    title: ttbStatus.temp.docId,
                    alternateTitle: 'Timetable settings',
                    subtitle: 'Timetable settings')),
            floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FloatingActionButton(
                      heroTag: 'Timetable Settings Cancel',
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop()),
                  SizedBox(width: 20.0),
                  FloatingActionButton(
                      heroTag: 'Timetable Settings Confirm',
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                      onPressed: () async {
                        ttbStatus.temp.docId = ttbStatus.temp.docId == null ||
                                ttbStatus.temp.docId.trim() == ''
                            ? _startDateWeek == _endDateWeek
                                ? 'Week $_startDateWeek'
                                : 'Week $_startDateWeek - $_endDateWeek'
                            : ttbStatus.temp.docId;
                        ttbStatus.temp.startDate = ttbStatus.temp.startDate ??
                            getClosestMondayBefore(defaultDate, defaultDate);
                        ttbStatus.temp.endDate = ttbStatus.temp.endDate ??
                            getClosestSundayAfter(defaultDate, defaultDate);

                        if (_formKey.currentState.validate() &&
                            ttbStatus.temp.isValid &&
                            ttbStatus.temp.groupsAreValid) {
                          // check if new timetable (docId is null)
                          // check if update same timetable (docId is same)
                          if (ttbStatus.edit.docId == ttbStatus.temp.docId) {
                            ttbStatus.edit.updateTimetableSettings(
                                docId: ttbStatus.temp.docId,
                                startDate: ttbStatus.temp.startDate,
                                endDate: ttbStatus.temp.endDate,
                                groups: ttbStatus.temp.groups,
                                members: groupStatus.members);
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
                                    ttbStatus.temp.metadata);

                            if (status.completed) {
                              Fluttertoast.showToast(msg: status.message);
                            }

                            if (status.success) {
                              // Update document with new data
                              ttbStatus.edit.updateTimetableSettings(
                                  docId: ttbStatus.temp.docId,
                                  startDate: ttbStatus.temp.startDate,
                                  endDate: ttbStatus.temp.endDate,
                                  groups: ttbStatus.temp.groups,
                                  members: groupStatus.members);
                              ttbStatus.update();
                              Navigator.of(context).maybePop();
                            }
                          }
                        } else {
                          if (ttbStatus.temp.startDate == null ||
                              ttbStatus.temp.endDate == null ||
                              !ttbStatus.temp.startDate
                                  .isBefore(ttbStatus.temp.endDate)) {
                            Fluttertoast.showToast(
                                msg: 'Invalid timetable dates');
                          } else if (!ttbStatus.temp.groupsAreValid) {
                            Fluttertoast.showToast(msg: 'Invalid axis values');
                          }
                        }
                      })
                ]),
            body: Column(
              children: <Widget>[
                // Timetable name
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: LabelTextInput(
                        key: _key1,
                        label: 'Name',
                        formKey: _formKey,
                        hintText: ttbStatus.temp.docId ?? _weekAsDocId(),
                        valSetText: (text) => setState(() =>
                            ttbStatus.temp.docId =
                                text == null || text.trim() == ''
                                    ? _weekAsDocId()
                                    : text),
                        validator: (text) => null)),
                SizedBox(height: 10.0),

                // Date range
                TimetableDateRange(
                    key: _key2,
                    initialStartDate: ttbStatus.temp.startDate ?? defaultDate,
                    initialEndDate: ttbStatus.temp.endDate ?? defaultDate,
                    valSetStartDate: (startDate) => setState(() {
                          ttbStatus.temp.startDate = startDate;
                          ttbStatus.temp
                              .validateAllGridDataList(groupStatus.members);
                          ttbStatus.update();

                          if (ttbStatus.temp.docId == _weekAsDocId()) {
                            _startDateWeek = ttbStatus.temp.startDate == null
                                ? getWeekOfYear(defaultDate)
                                : getWeekOfYear(ttbStatus.temp.startDate);
                            ttbStatus.temp.docId = _weekAsDocId();
                          }
                        }),
                    valSetEndDate: (endDate) => setState(() {
                          ttbStatus.temp.endDate = endDate;
                          ttbStatus.temp
                              .validateAllGridDataList(groupStatus.members);
                          ttbStatus.update();

                          if (ttbStatus.temp.docId == _weekAsDocId()) {
                            _endDateWeek = ttbStatus.temp.endDate == null
                                ? getWeekOfYear(defaultDate)
                                : getWeekOfYear(ttbStatus.temp.endDate);
                            ttbStatus.temp.docId = _weekAsDocId();
                          }
                        })),
                SizedBox(height: 10.0),

                // Groups
                TimetableGroupSelector(
                    valGetGroups: () => ttbStatus.temp.groups,
                    valSetGroups: (value) =>
                        setState(() => ttbStatus.temp.groups = value),
                    valGetGroupSelected: () => ttbStatus.tempGroupIndex,
                    valSetGroupSelected: (value) {
                      setState(() => ttbStatus.tempGroupIndex = value);
                    }),

                Expanded(
                  child: ListView(
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      children: <Widget>[
                        // Axis Day
                        Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: AxisDay(
                                initialWeekdaysSelected:
                                    ttbStatus.temp.groups[index].axisDay,
                                valSetWeekdaysSelected:
                                    (timetableWeekdaysSelected) => setState(
                                        () => ttbStatus.temp.setGroupAxisDay(
                                            index, timetableWeekdaysSelected)),
                                valGetWeekdaysSelected: () =>
                                    ttbStatus.temp.groups[index].axisDay)),
                        Divider(thickness: 1.0),

                        // Axis Time
                        Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: AxisTime(
                                initialTimes:
                                    ttbStatus.temp.groups[index].axisTime,
                                valSetTimes: (times) => setState(() => ttbStatus
                                    .temp
                                    .setGroupAxisTime(index, times)),
                                valGetTimes: () =>
                                    ttbStatus.temp.groups[index].axisTime)),

                        Divider(thickness: 1.0),

                        // Axis Custom
                        Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: AxisCustom(
                                initialCustoms:
                                    ttbStatus.temp.groups[index].axisCustom,
                                valSetCustoms: (customVals) => setState(() =>
                                    ttbStatus.temp
                                        .setGroupAxisCustom(index, customVals)),
                                valGetCustoms: () =>
                                    ttbStatus.temp.groups[index].axisCustom)),
                        Divider(thickness: 1.0),

                        // Delete button
                        Padding(
                            padding: EdgeInsets.all(20.0),
                            child: RaisedButton(
                                color: Colors.red.shade300,
                                highlightColor: Colors.red.shade500,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text('DELETE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                        ))),
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleAlertDialog(
                                            context: context,
                                            contentDisplay:
                                                'Do you want to delete \'${ttbStatus.temp.docId}\' timetable?',
                                            confirmDisplay: 'DELETE',
                                            confirmFunction: () async {
                                              Navigator.of(context).maybePop();

                                              _scaffoldKey.currentState
                                                  .showSnackBar(LoadingSnackBar(
                                                      context,
                                                      'Deleting timetable . . .'));

                                              await dbService
                                                  .deleteGroupTimetable(
                                                      groupStatus.group.docId,
                                                      ttbStatus.edit.docId)
                                                  .then((_) {
                                                _scaffoldKey.currentState
                                                    .hideCurrentSnackBar();

                                                Fluttertoast.showToast(
                                                    msg:
                                                        'Successfully deleted timetable');
                                              });
                                            });
                                      });
                                })),
                        SizedBox(height: 100.0),
                      ]),
                ),
              ],
            )));
  }
}
