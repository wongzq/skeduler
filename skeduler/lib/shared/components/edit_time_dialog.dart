import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:skeduler/shared/components/custom_time_picker.dart';

class EditTimeDialog extends StatefulWidget {
  final String contentText;
  final DateTime initialStartTime;
  final DateTime initialEndTime;
  final ValueSetter<DateTime> valSetStartTime;
  final ValueSetter<DateTime> valSetEndTime;
  final void Function() onSave;

  const EditTimeDialog({
    Key key,
    this.contentText = 'Edit Time',
    this.initialStartTime,
    this.initialEndTime,
    this.valSetStartTime,
    this.valSetEndTime,
    this.onSave,
  }) : super(key: key);

  @override
  _EditTimeDialogState createState() => _EditTimeDialogState();
}

class _EditTimeDialogState extends State<EditTimeDialog> {
  /// properties
  DateTime _startTime = DateTime(DateTime.now().year);
  DateTime _endTime = DateTime(DateTime.now().year);
  String _startTimeStr;
  String _endTimeStr;

  bool _validTime = false;

  double _spacing = 5.0;
  double _bodyPadding = 10.0;
  double _centerWidth = 20.0;
  double _buttonHeight = 45.0;

  /// validate time
  void _validateTime() {
    if (_endTime.isAfter(_startTime)) {
      _validTime = true;
    } else {
      _validTime = false;
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
                    if (widget.valSetStartTime != null)
                      widget.valSetStartTime(_startTime);
                  } else if (end) {
                    _endTimeStr = DateFormat('hh:mm aa').format(time);
                    _endTime = time;
                    if (widget.valSetEndTime != null)
                      widget.valSetEndTime(_endTime);
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

  @override
  void initState() {
    if (widget.initialStartTime != null) {
      _startTime = widget.initialStartTime;
      _startTimeStr = DateFormat('hh:mm aa').format(_startTime);
    }
    if (widget.initialEndTime != null) {
      _endTime = widget.initialEndTime ?? _endTime;
      _endTimeStr = DateFormat('hh:mm aa').format(_endTime);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.contentText,
        style: TextStyle(fontSize: 16.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /// Button: Start Time
          generateTimePicker(start: true),

          SizedBox(height: 10.0),

          /// Button: End Time
          generateTimePicker(end: true),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text('SAVE'),
          onPressed: () {
            if (_validTime && widget.onSave != null) {
              widget.onSave();
            }
            Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }
}
