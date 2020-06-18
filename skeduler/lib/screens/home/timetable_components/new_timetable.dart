import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/navigation/route_arguments.dart';
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

enum CopyTimetableType { copyTimetable, copyTimetableAxes }

class CopyTimetableData {
  String ttbId;
  CopyTimetableType copyType;

  CopyTimetableData({@required this.ttbId, @required this.copyType});
}

class NewTimetable extends StatefulWidget {
  @override
  _NewTimetableState createState() => _NewTimetableState();
}

class _NewTimetableState extends State<NewTimetable> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey _key1 = GlobalKey();
  GlobalKey _key2 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);

    int index = ttbStatus.tempGroupIndex;

    return GestureDetector(
        onTap: () => unfocus(),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(
                      Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
                  onPressed: () {
                    ttbStatus.temp = EditTimetable();
                    Navigator.of(context).maybePop();
                  }),
              title: AppBarTitle(title: 'New Timetable'),
              actions: <Widget>[
                PopupMenuButton<CopyTimetableData>(
                  icon: Icon(Icons.content_copy),
                  itemBuilder: (context) {
                    List<PopupMenuEntry<CopyTimetableData>> popupOptions = [];

                    groupStatus.group.timetableMetadatas
                        .forEach((timetableMetadata) {
                      popupOptions.add(
                        PopupMenuItem<CopyTimetableData>(
                          value: CopyTimetableData(
                            ttbId: timetableMetadata.docId,
                            copyType: CopyTimetableType.copyTimetable,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Copy ' + timetableMetadata.docId),
                            ],
                          ),
                        ),
                      );

                      popupOptions.add(
                        PopupMenuItem<CopyTimetableData>(
                          value: CopyTimetableData(
                            ttbId: timetableMetadata.docId,
                            copyType: CopyTimetableType.copyTimetableAxes,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Copy ' + timetableMetadata.docId + ' axes'),
                            ],
                          ),
                        ),
                      );

                      if (timetableMetadata !=
                          groupStatus.group.timetableMetadatas.last) {
                        popupOptions.add(PopupMenuDivider(height: 1.0));
                      }
                    });

                    return popupOptions;
                  },
                  onSelected: (CopyTimetableData value) async {
                    await dbService
                        .getGroupTimetableWithGroups(
                      groupStatus.group.docId,
                      value.ttbId,
                    )
                        .then((timetable) {
                      if (value.copyType == CopyTimetableType.copyTimetable) {
                        if (ttbStatus.temp.startDate != null &&
                            ttbStatus.temp.endDate != null &&
                            ttbStatus.temp.startDate
                                .isBefore(ttbStatus.temp.endDate)) {
                          setState(() {
                            ttbStatus.temp.updateTimetableFromCopy(
                                timetable, groupStatus.members);
                          });
                          Fluttertoast.showToast(
                              msg: 'Successfully copied ' + value.ttbId);
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Please provide dates before copying');
                        }
                      } else if (value.copyType ==
                          CopyTimetableType.copyTimetableAxes) {
                        setState(() {
                          ttbStatus.temp.updateTimetableFromCopyAxes(timetable);
                        });

                        Fluttertoast.showToast(
                            msg:
                                'Successfully copied ' + value.ttbId + ' axes');
                      }
                    });
                  },
                ),
              ],
            ),
            body: ListView(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: <Widget>[
                  // Timetable name
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: LabelTextInput(
                      key: _key1,
                      label: 'Name',
                      formKey: _formKey,
                      hintText: 'Timetable Name',
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
                  TimetableDateRange(
                    key: _key2,
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

                  // Groups
                  TimetableGroupSelector(
                      valGetGroups: () => ttbStatus.temp.groups,
                      valSetGroups: (value) =>
                          setState(() => ttbStatus.temp.groups = value),
                      valGetGroupSelected: () => ttbStatus.tempGroupIndex,
                      valSetGroupSelected: (value) =>
                          setState(() => ttbStatus.tempGroupIndex = value)),

                  // Axis Day
                  Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: AxisDay(
                          initialWeekdaysSelected:
                              ttbStatus.temp.groups[index].axisDay,
                          valSetWeekdaysSelected: (timetableWeekdaysSelected) =>
                              ttbStatus.temp.setGroupAxisDay(
                                  index, timetableWeekdaysSelected),
                          valGetWeekdaysSelected: () =>
                              ttbStatus.temp.groups[index].axisDay)),
                  Divider(thickness: 1.0),

                  // Axis Time
                  Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: AxisTime(
                          initialTimes: ttbStatus.temp.groups[index].axisTime,
                          valSetTimes: (times) =>
                              ttbStatus.temp.setGroupAxisTime(index, times),
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
                          valSetCustoms: (customVals) => ttbStatus.temp
                              .setGroupAxisCustom(index, customVals),
                          valGetCustoms: () =>
                              ttbStatus.temp.groups[index].axisCustom)),
                  Divider(thickness: 1.0),

                  // Create button
                  Padding(
                      padding: EdgeInsets.all(20.0),
                      child: RaisedButton(
                          textColor: originTheme.textColor,
                          color: originTheme.primaryColor,
                          highlightColor: originTheme.primaryColorDark,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('CREATE',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5))),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              unfocus();

                              if (ttbStatus.temp.startDate != null &&
                                  ttbStatus.temp.endDate != null &&
                                  ttbStatus.temp.startDate
                                      .isBefore(ttbStatus.temp.endDate)) {
                                _scaffoldKey.currentState.showSnackBar(
                                    LoadingSnackBar(
                                        context, 'Creating timetable . . .'));

                                List<TimetableMetadata> timetableMetadatas =
                                    List.from(
                                        groupStatus.group.timetableMetadatas);

                                timetableMetadatas.add(
                                  TimetableMetadata(
                                    docId: ttbStatus.temp.docId,
                                    startDate: Timestamp.fromDate(
                                        ttbStatus.temp.startDate),
                                    endDate: Timestamp.fromDate(
                                        ttbStatus.temp.endDate),
                                  ),
                                );

                                if (isConsecutiveTimetables(
                                    timetableMetadatas)) {
                                  bool nameFound = false;
                                  groupStatus.group.timetableMetadatas
                                      .forEach((timetableMetadata) {
                                    if (timetableMetadata.docId ==
                                        ttbStatus.temp.docId) {
                                      nameFound = true;
                                    }
                                  });

                                  if (nameFound) {
                                    Fluttertoast.showToast(
                                        msg: 'Timetable ID already exists');
                                  } else {
                                    dbService
                                        .updateGroupTimetable(
                                      groupStatus.group.docId,
                                      ttbStatus.temp,
                                    )
                                        .then((_) {
                                      _scaffoldKey.currentState
                                          .hideCurrentSnackBar();
                                      ttbStatus.edit =
                                          EditTimetable.from(ttbStatus.temp);
                                      ttbStatus.temp = null;

                                      Navigator.of(context).popAndPushNamed(
                                        '/timetables/editor',
                                        arguments: RouteArgs(),
                                      );
                                    });
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Timetable dates clash');
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'Timetable dates are invalid');
                              }
                            }
                          })),
                  SizedBox(height: 100.0),
                ])));
  }
}
