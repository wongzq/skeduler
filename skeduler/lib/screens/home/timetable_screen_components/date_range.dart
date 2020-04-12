import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRange extends StatefulWidget {
  final String contentText;
  final DateTime initialStartTime;
  final DateTime initialEndTime;
  final ValueSetter<DateTime> valSetStartTime;
  final ValueSetter<DateTime> valSetEndTime;
  final void Function() onSave;

  const DateRange({
    Key key,
    this.contentText = 'Edit Time',
    this.initialStartTime,
    this.initialEndTime,
    this.valSetStartTime,
    this.valSetEndTime,
    this.onSave,
  }) : super(key: key);

  @override
  _DateRangeState createState() => _DateRangeState();
}

class _DateRangeState extends State<DateRange> {
  /// Properties
  DateTime _startDate = DateTime(DateTime.now().year);
  DateTime _endDate = DateTime(DateTime.now().year);
  String _startDateStr;
  String _endDateStr;

  bool _validDate = false;

  double _spacing = 5.0;
  double _bodyPadding = 10.0;
  double _centerWidth = 20.0;
  double _buttonHeight = 45.0;

  /// validate date
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

  bool _validateStartEndDate(DateTime date) {
    // if ((date.isAfter(getFirstDayOfStartMonth()) ||
    //         date.isAtSameMomentAs(getFirstDayOfStartMonth())) &&
    //     (date.isBefore(getLastDayOfLastMonth().add(Duration(days: 1))))) {
    //   return true;
    // } else {
    //   return false;
    // }

    return true;
  }

  /// generate DatePicker widget for Start Date and End Date
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
                  firstDate: DateTime(
                    DateTime.now().subtract(Duration(days: 365)).year,
                  ),
                  lastDate: DateTime(
                    DateTime.now().add(Duration(days: 365)).year,
                  ),
                  initialDate: () {
                    if (start) {
                      DateTime prevDateTime = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      );
                      if (DateTime.now().weekday != 1) {
                        while (true) {
                          prevDateTime =
                              prevDateTime.subtract(Duration(days: 1));
                          if (prevDateTime.weekday == 1) {
                            break;
                          }
                        }
                      }
                      return prevDateTime;
                    } else if (end) {
                      DateTime nextDateTime = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      );
                      if (DateTime.now().weekday != 7) {
                        while (true) {
                          nextDateTime = nextDateTime.add(Duration(days: 1));
                          if (nextDateTime.weekday == 7) {
                            break;
                          }
                        }
                      }
                      return nextDateTime;
                    } else {
                      return null;
                    }
                  }(),
                  selectableDayPredicate: (date) {
                    if (start) {
                      return date.weekday == 1;
                    } else if (end) {
                      return date.weekday == 7;
                    } else {
                      return null;
                    }
                  });

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
    _startDate = widget.initialStartTime ?? _startDate;
    _endDate = widget.initialEndTime ?? _endDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        /// Button: Start Time
        generateDatePicker(start: true),

        SizedBox(width: 5.0),
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
        SizedBox(width: 5.0),

        /// Button: End Time
        generateDatePicker(end: true),
      ],
    );
  }
}
