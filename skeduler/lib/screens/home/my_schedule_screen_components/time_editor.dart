import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quiver/time.dart';
import 'package:skeduler/models/auxiliary/native_theme.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/editors_status.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/custom_time_picker.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimeEditor extends StatefulWidget {
  final ValueGetter<List<Month>> valGetMonths;
  final ValueGetter<List<Weekday>> valGetWeekdays;

  const TimeEditor({
    Key key,
    @required this.valGetMonths,
    @required this.valGetWeekdays,
  }) : super(key: key);

  @override
  _TimeEditorState createState() => _TimeEditorState();
}

class _TimeEditorState extends State<TimeEditor> {
  /// properties
  GlobalKey _textKey = GlobalKey();
  GlobalKey _sizedBoxKey = GlobalKey();
  GlobalKey _buttonsKey = GlobalKey();

  EditorsStatus _editorsStatus;

  DateTime _startDate;
  DateTime _endDate;
  String _startDateStr;
  String _endDateStr;

  DateTime _startTime = DateTime(DateTime.now().year);
  DateTime _endTime = DateTime(DateTime.now().year);
  String _startTimeStr;
  String _endTimeStr;

  bool _validTime = false;
  bool _validDate = true;

  bool _dateRangeExpanded;

  double _spacing = 5.0;
  double _bodyPadding = 10.0;
  double _centerWidth = 20.0;
  double _buttonHeight = 45.0;

  /// methods
  /// set the selected height of time editor
  void setTimeEditorSelectedHeight() {
    RenderBox text = _textKey.currentContext.findRenderObject();
    RenderBox sizedBox = _sizedBoxKey.currentContext.findRenderObject();
    RenderBox buttons = _buttonsKey.currentContext.findRenderObject();

    _editorsStatus.timeEditorSelectedHeight = text.size.height +
        sizedBox.size.height +
        buttons.size.height +
        2 * _bodyPadding;
  }

  /// validate time
  void _validateTime() {
    if (_endTime.isAfter(_startTime)) {
      _validTime = true;
    } else {
      _validTime = false;
    }
  }

  void _validateDate() {
    if (_startDate == null && _endDate == null) {
      _validDate = true;
    } else if (_startDate != null && _endDate != null) {
      if (_endDate.isAfter(_startDate) ||
          _endDate.isAtSameMomentAs(_startDate)) {
        _validDate = true;
      } else {
        _validDate = false;
      }
    } else {
      _validDate = false;
    }
  }

  DateTime getFirstDayOfStartMonth() {
    if (widget.valGetMonths != null) {
      return DateTime(
        DateTime.now().year,
        widget.valGetMonths().first.index + 1,
      );
    } else {
      return null;
    }
  }

  DateTime getLastDayOfLastMonth() {
    if (widget.valGetMonths != null) {
      return DateTime(
          DateTime.now().year,
          widget.valGetMonths().last.index + 1,
          daysInMonth(
            DateTime.now().year,
            widget.valGetMonths().last.index + 1,
          ));
    } else {
      return null;
    }
  }

  bool _validateStartEndDate(DateTime date) {
    if ((date.isAfter(getFirstDayOfStartMonth()) ||
            date.isAtSameMomentAs(getFirstDayOfStartMonth())) &&
        (date.isBefore(getLastDayOfLastMonth().add(Duration(days: 1))))) {
      return true;
    } else {
      return false;
    }
  }

  /// generate TimePicker widget for Start Time and End Time
  Widget generateTimePicker({bool start = false, bool end = false}) {
    if ((start && !end) || (!start && end)) {
      return Container(
        width: (MediaQuery.of(context).size.width -
                _bodyPadding * 2 -
                _spacing * 2 -
                _centerWidth) /
            2,
        child: Padding(
          padding: EdgeInsets.all(_spacing),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 3.0,
            onPressed: () {
              DatePicker.showPicker(
                context,
                theme: DatePickerTheme(
                  containerHeight: MediaQuery.of(context).size.height / 3,
                ),
                showTitleActions: true,
                onConfirm: (time) {
                  if (start) {
                    _startTimeStr = DateFormat('hh:mm aa').format(time);
                    _startTime = time;
                  } else if (end) {
                    _endTimeStr = DateFormat('hh:mm aa').format(time);
                    _endTime = time;
                  }
                  _validateTime();
                  setState(() {});
                },
                pickerModel: CustomTimePicker(
                  currentTime: () {
                    if (start) {
                      return _startTime;
                    } else if (end) {
                      return _endTime;
                    } else {
                      return null;
                    }
                  }(),
                  locale: LocaleType.en,
                  interval: 5,
                ),
              );
              setState(() {});
            },
            child: Container(
              alignment: Alignment.center,
              height: _buttonHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              size: 20.0,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              () {
                                if (start) {
                                  return _startTimeStr ?? 'Start time';
                                } else if (end) {
                                  return _endTimeStr ?? 'End time';
                                } else {
                                  return 'Not set';
                                }
                              }(),
                              style: () {
                                if ((start && _startTimeStr != null) ||
                                    (end && _endTimeStr != null)) {
                                  return TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                  );
                                } else {
                                  return TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.0,
                                  );
                                }
                              }(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            color: Colors.white,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget generateDatePicker({bool start = false, bool end = false}) {
    if ((start && !end) || (!start && end)) {
      return Container(
        width: (MediaQuery.of(context).size.width -
                _bodyPadding * 2 -
                _spacing * 2 -
                _centerWidth) /
            2,
        child: Padding(
          padding: EdgeInsets.all(_spacing),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 3.0,
            onPressed: () async {
              DateTime date = await showDatePicker(
                context: context,
                firstDate: getFirstDayOfStartMonth(),
                lastDate: getLastDayOfLastMonth(),
                initialDate: () {
                  if (start) {
                    return _startDate != null
                        ? _startDate
                        : getFirstDayOfStartMonth();
                  } else if (end) {
                    return _endDate != null
                        ? _endDate
                        : getLastDayOfLastMonth();
                  } else {
                    return DateTime.now();
                  }
                }(),
              );

              if (start && _validateStartEndDate(date)) {
                _startDateStr = DateFormat('yyyy/MM/dd').format(date);
                _startDate = date;
              } else if (end && _validateStartEndDate(date)) {
                _endDateStr = DateFormat('yyyy/MM/dd').format(date);
                _endDate = date;
              }

              _validateDate();
              setState(() {});
            },
            child: Container(
              alignment: Alignment.center,
              height: _buttonHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              size: 20.0,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              () {
                                if (start) {
                                  return _startDateStr ?? 'Start date';
                                } else if (end) {
                                  return _endDateStr ?? 'End date';
                                } else {
                                  return 'Not set';
                                }
                              }(),
                              style: () {
                                if ((start && _startDateStr != null) ||
                                    (end && _endDateStr != null)) {
                                  return TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                  );
                                } else {
                                  return TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.0,
                                  );
                                }
                              }(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            color: Colors.white,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  void initState() {
    _dateRangeExpanded = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setTimeEditorSelectedHeight();
      setState(() {
        _dateRangeExpanded = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<Group> group = Provider.of<ValueNotifier<Group>>(context);
    _editorsStatus = Provider.of<EditorsStatus>(context);

    return AbsorbPointer(
      absorbing:
          widget.valGetMonths().isEmpty || widget.valGetWeekdays().isEmpty,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            setState(() => _editorsStatus.currentEditor = CurrentEditor.time),
        child: AnimatedContainer(
          duration: _editorsStatus.duration,
          curve: _editorsStatus.curve,
          height: _editorsStatus.timeEditorHeight ??
              _editorsStatus.defaultSecondaryHeight,
          width: _editorsStatus.totalWidth,
          child: Padding(
            padding: EdgeInsets.all(_bodyPadding),
            child: Column(
              children: <Widget>[
                /// Title
                Align(
                  alignment: Alignment.topCenter,
                  child: Text('Time', key: _textKey, style: textStyleHeader),
                ),

                SizedBox(key: _sizedBoxKey, height: _spacing),

                /// Body: Set Time Buttons
                Visibility(
                  visible: _editorsStatus.currentEditor == CurrentEditor.time,
                  maintainSize: true,
                  maintainState: true,
                  maintainAnimation: true,
                  child: Column(
                    key: _buttonsKey,
                    children: <Widget>[
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: GlobalKey(),
                          initiallyExpanded: _dateRangeExpanded,
                          onExpansionChanged: (val) {
                            _dateRangeExpanded = val;
                          },
                          title: Text(
                            'Date range (optional)',
                            style: textStyleBodyLight.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                /// Button: Start Date
                                generateDatePicker(start: true),

                                SizedBox(width: _spacing),
                                Container(
                                  alignment: Alignment.center,
                                  width: _centerWidth,
                                  child: Text(
                                    'to',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(width: _spacing),

                                /// Button: End Date
                                generateDatePicker(end: true),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          /// Button: Start Time
                          generateTimePicker(start: true),

                          SizedBox(width: _spacing),
                          Container(
                            alignment: Alignment.center,
                            width: _centerWidth,
                            child: Text(
                              'to',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(width: _spacing),

                          /// Button: End Time
                          generateTimePicker(end: true),
                        ],
                      ),

                      SizedBox(height: _spacing),

                      /// Button: Save
                      Padding(
                        padding: EdgeInsets.all(_spacing),
                        child: Container(
                          height: _buttonHeight,
                          width: MediaQuery.of(context).size.width - 2,
                          child: RaisedButton(
                            color: originTheme.primaryColorLight,
                            disabledColor: Colors.grey[200],
                            disabledTextColor: Color(0xFFBBBBBB),
                            highlightColor: originTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 3.0,
                            onPressed: _validTime && _validDate
                                ? () async {
                                    List<Time> newTimes = generateTimes(
                                      months: widget.valGetMonths(),
                                      weekDays: widget.valGetWeekdays(),
                                      time: Time(_startTime, _endTime),
                                      startDate: _startDate ??
                                          getFirstDayOfStartMonth(),
                                      endDate:
                                          _endDate ?? getLastDayOfLastMonth(),
                                    );
                                    await dbService.updateGroupMemberTimes(
                                        group.value.docId, null, newTimes);
                                  }
                                : null,
                            child: Text(
                              'SAVE',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: _spacing),

                      /// Button: Remove
                      Padding(
                        padding: EdgeInsets.all(_spacing),
                        child: Container(
                          height: _buttonHeight,
                          width: MediaQuery.of(context).size.width - 2,
                          child: RaisedButton(
                            color: Colors.red[300],
                            disabledColor: Colors.grey[200],
                            disabledTextColor: Color(0xFFBBBBBB),
                            highlightColor: Colors.red[500],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 3.0,
                            onPressed: _validDate
                                ? () async {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        'Remove from your schedule?\n\n',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: DateFormat(
                                                                'EEEE, d MMMM')
                                                            .format(
                                                          _startDate ??
                                                              getFirstDayOfStartMonth(),
                                                        ) +
                                                        ' to ' +
                                                        DateFormat(
                                                                'EEEE, d MMMM')
                                                            .format(
                                                          _endDate ??
                                                              getLastDayOfLastMonth(),
                                                        ),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('CANCEL'),
                                                onPressed: () =>
                                                    Navigator.of(context).maybePop(),
                                              ),
                                              FlatButton(
                                                  child: Text(
                                                    'REMOVE',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    List<Time> removeTimes =
                                                        generateTimes(
                                                      months:
                                                          widget.valGetMonths(),
                                                      weekDays: widget
                                                          .valGetWeekdays(),
                                                      time: Time(
                                                          _startTime, _endTime),
                                                      startDate: _startDate ??
                                                          getFirstDayOfStartMonth(),
                                                      endDate: _endDate ??
                                                          getLastDayOfLastMonth(),
                                                    );

                                                    await dbService
                                                        .removeGroupMemberTimes(
                                                      group.value.docId,
                                                      null,
                                                      removeTimes,
                                                    );
                                                    Navigator.of(context).maybePop();
                                                  }),
                                            ],
                                          );
                                        });
                                  }
                                : null,
                            child: Text(
                              'REMOVE',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: _spacing),

                      /// Button: Reset
                      Padding(
                        padding: EdgeInsets.all(_spacing),
                        child: Container(
                          height: _buttonHeight,
                          width: MediaQuery.of(context).size.width - 2,
                          child: RaisedButton(
                            color: Theme.of(context).primaryColorLight,
                            highlightColor: Theme.of(context).primaryColorDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 3.0,
                            onPressed: () {
                              _startTime = DateTime(DateTime.now().year);
                              _startTimeStr = null;
                              _endTime = DateTime(DateTime.now().year);
                              _endTimeStr = null;
                              _startDate = null;
                              _startDateStr = null;
                              _endDate = null;
                              _endDateStr = null;
                              _validateTime();
                              _validateDate();
                              setState(() {});
                            },
                            child: Text(
                              'RESET',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
