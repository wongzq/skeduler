import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:skeduler/shared/widgets/custom_time_picker.dart';

enum TimeSelectorType { start, end }

class TimeSelector extends StatefulWidget {
  final BuildContext context;
  final TimeSelectorType type;
  final ValueSetter<DateTime> valSetStartTime;
  final ValueSetter<DateTime> valSetEndTime;
  final ValueSetter<bool> valSetValidTime;
  final ValueGetter<DateTime> valGetStartTime;
  final ValueGetter<DateTime> valGetEndTime;

  TimeSelector({
    Key key,
    @required this.context,
    @required this.type,
    @required this.valSetStartTime,
    @required this.valSetEndTime,
    @required this.valGetStartTime,
    @required this.valGetEndTime,
    @required this.valSetValidTime,
  }) : super(key: key);

  @override
  _TimeSelectorState createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  DateTime _defaultStartTime;
  DateTime _defaultEndTime;
  DateTime _startTime;
  DateTime _endTime;
  String _startTimeStr;
  String _endTimeStr;

  double _spacing = 5.0;
  double _bodyPadding = 10.0;
  double _centerWidth = 20.0;
  double _buttonHeight = 45.0;

  // validate time
  bool _validateTime() {
    if (_startTime == null || _endTime == null) {
      return false;
    } else if (_endTime.isAfter(_startTime)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _defaultStartTime = DateTime(DateTime.now().year, 1, 1, 0, 0);
    _defaultEndTime = DateTime(DateTime.now().year, 1, 1, 23, 59);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _startTime = widget.valGetStartTime();
    _endTime = widget.valGetEndTime();
    if (_startTime != null) {
      _startTimeStr = DateFormat('hh:mm aa').format(_startTime);
    }
    if (_endTime != null) {
      _endTimeStr = DateFormat('hh:mm aa').format(_endTime);
    }

    return Container(
      width: (MediaQuery.of(context).size.width -
              _bodyPadding * 2 -
              _spacing * 2 -
              _centerWidth) /
          2,
      child: Padding(
        padding: EdgeInsets.all(_spacing),
        child: RaisedButton(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 3.0,
          onPressed: () => setState(() {
            DatePicker.showPicker(
              context,
              showTitleActions: true,
              theme: DatePickerTheme(
                containerHeight: MediaQuery.of(context).size.height / 3,
              ),
              pickerModel: CustomTimePicker(
                currentTime: widget.type == TimeSelectorType.start
                    ? _startTime ?? _defaultStartTime
                    : widget.type == TimeSelectorType.end
                        ? _endTime ?? _defaultEndTime
                        : null,
                locale: LocaleType.en,
                interval: 5,
              ),
              onConfirm: (time) {
                setState(() {
                  if (widget.type == TimeSelectorType.start) {
                    _startTime = time;
                    _startTimeStr = DateFormat('hh:mm aa').format(time);

                    if (widget.valSetStartTime != null)
                      widget.valSetStartTime(_startTime);
                  } else if (widget.type == TimeSelectorType.end) {
                    _endTime = time;
                    _endTimeStr = DateFormat('hh:mm aa').format(time);

                    if (widget.valSetEndTime != null)
                      widget.valSetEndTime(_endTime);
                  }

                  if (widget.valSetValidTime != null) {
                    widget.valSetValidTime(_validateTime());
                  }
                });
              },
            );
          }),
          child: Container(
            height: _buttonHeight,
            alignment: Alignment.center,
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20.0,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 10.0),
                Text(
                  widget.type == TimeSelectorType.start
                      ? (_startTimeStr ?? 'Start time')
                      : widget.type == TimeSelectorType.end
                          ? (_endTimeStr ?? 'End time')
                          : '',
                  style: (widget.type == TimeSelectorType.start &&
                              _startTimeStr != null) ||
                          (widget.type == TimeSelectorType.end &&
                              _endTimeStr != null)
                      ? TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0,
                        )
                      : TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0,
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
