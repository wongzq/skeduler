import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/screens/home/profile_screen_components/custom_time_picker.dart';
import 'package:skeduler/screens/home/profile_screen_components/editors_status.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimeEditor extends StatefulWidget {
  @override
  _TimeEditorState createState() => _TimeEditorState();
}

class _TimeEditorState extends State<TimeEditor> {
  // properties
  GlobalKey _textKey = GlobalKey();
  GlobalKey _sizedBoxKey = GlobalKey();
  GlobalKey _buttonsKey = GlobalKey();

  EditorsStatus _editorsStatus;

  DateTime _startTime = DateTime(DateTime.now().year);
  DateTime _endTime = DateTime(DateTime.now().year);
  String _startTimeStr;
  String _endTimeStr;

  bool _validTime = false;

  static const double _spacing = 5.0;
  static const double _bodyPadding = 10.0;
  static const double _centerWidth = 20.0;
  static const double _buttonHeight = 45.0;

  // methods
  // set the selected height of time editor
  setTimeEditorSelectedHeight() {
    RenderBox text = _textKey.currentContext.findRenderObject();
    RenderBox sizedBox = _sizedBoxKey.currentContext.findRenderObject();
    RenderBox buttons = _buttonsKey.currentContext.findRenderObject();

    _editorsStatus.timeEditorSelectedHeight = text.size.height +
        sizedBox.size.height +
        buttons.size.height +
        2 * _bodyPadding;
    print(_editorsStatus.timeEditorSelectedHeight);
  }

  // validate time
  void _validateTime() {
    print('Start ${_startTime.hour} ${_startTime.minute}');
    print('End ${_endTime.hour} ${_endTime.minute}');

    if (_endTime.isAfter(_startTime)) {
      _validTime = true;
    } else {
      _validTime = false;
    }
  }

  // generate TimePicker widget for Start Time and End Time
  Widget generateTimePicker({bool start = false, bool end = false}) {
    if ((start && !end) || (!start && end)) {
      return Container(
        width: (MediaQuery.of(context).size.width -
                _bodyPadding * 2 -
                _spacing * 2 -
                _centerWidth) /
            2,
        child: Padding(
          padding: const EdgeInsets.all(_spacing),
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
                                ;
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

  @override
  void initState() {
    SchedulerBinding.instance
        .addPostFrameCallback((_) => setTimeEditorSelectedHeight());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _editorsStatus = Provider.of<EditorsStatus>(context);

    return GestureDetector(
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
          padding: const EdgeInsets.all(_bodyPadding),
          child: Column(
            children: <Widget>[
              // Title
              Align(
                alignment: Alignment.topCenter,
                child: Text('Time', key: _textKey, style: textStyleHeader),
              ),

              SizedBox(key: _sizedBoxKey, height: _spacing),

              // Body: Set Time Buttons
              Visibility(
                visible: _editorsStatus.currentEditor == CurrentEditor.time,
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
                child: Column(
                  key: _buttonsKey,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        // Button: Start Time
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

                        // Button: End Time
                        generateTimePicker(end: true),
                      ],
                    ),

                    SizedBox(height: _spacing),

                    // Button: Save
                    Padding(
                      padding: const EdgeInsets.all(_spacing),
                      child: Container(
                        height: _buttonHeight,
                        width: MediaQuery.of(context).size.width - 2,
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorLight,
                          disabledColor: Colors.grey[200],
                          disabledTextColor: Color(0xFFBBBBBB),
                          highlightColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 3.0,
                          onPressed: _validTime ? () {} : null,
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

                    // Button: Reset
                    Padding(
                      padding: const EdgeInsets.all(_spacing),
                      child: Container(
                        height: _buttonHeight,
                        width: MediaQuery.of(context).size.width - 2,
                        child: RaisedButton(
                          color: Colors.red[300],
                          highlightColor: Colors.red[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 3.0,
                          onPressed: () {
                            _startTime = DateTime(DateTime.now().year);
                            _startTimeStr = null;
                            _endTime = DateTime(DateTime.now().year);
                            _endTimeStr = null;
                            _validateTime();
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
    );
  }
}
