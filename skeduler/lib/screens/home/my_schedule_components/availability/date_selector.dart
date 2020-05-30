import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/shared/functions.dart';

enum DateSelectorType { start, end }

class DateSelector extends StatefulWidget {
  final BuildContext context;
  final DateSelectorType type;
  final ValueSetter<DateTime> valSetStartDate;
  final ValueSetter<DateTime> valSetEndDate;
  final ValueSetter<bool> valSetValidDate;
  final ValueGetter<DateTime> valGetStartDate;
  final ValueGetter<DateTime> valGetEndDate;

  final ValueGetter<List<Month>> valGetMonths;

  final DateTime initialStartDate;
  final DateTime initialEndDate;

  DateSelector({
    Key key,
    @required this.context,
    @required this.type,
    this.valSetStartDate,
    this.valSetEndDate,
    this.valGetStartDate,
    this.valGetEndDate,
    this.valSetValidDate,
    this.valGetMonths,
    this.initialStartDate,
    this.initialEndDate,
  }) : super(key: key);

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime _defaultStartDate;
  DateTime _defaultEndDate;

  DateTime _startDate;
  DateTime _endDate;
  String _startDateStr;
  String _endDateStr;

  double _spacing = 5.0;
  double _bodyPadding = 10.0;
  double _centerWidth = 20.0;
  double _buttonHeight = 45.0;

  bool _validateDate() {
    if (_startDate == null || _endDate == null) {
      return false;
    } else if (_endDate.isAfter(_startDate) ||
        _endDate.isAtSameMomentAs(_startDate)) {
      return true;
    } else {
      return false;
    }
  }

  bool _validateStartEndDateRange(DateTime date) {
    if ((date.isAfter(_defaultStartDate) ||
            date.isAtSameMomentAs(_defaultStartDate)) &&
        (date.isBefore(_defaultEndDate.add(Duration(days: 1))))) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _defaultStartDate = widget.valGetMonths == null
        ? DateTime.now().add(Duration(days: -30))
        : getFirstDayOfStartMonth(widget.valGetMonths());
    _defaultEndDate = widget.valGetMonths == null
        ? DateTime.now().add(Duration(days: 365))
        : getLastDayOfLastMonth(widget.valGetMonths());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _startDate =
        widget.valGetStartDate == null ? null : widget.valGetStartDate();
    _endDate = widget.valGetEndDate == null ? null : widget.valGetEndDate();
    
    if (_startDate != null) {
      _startDateStr = DateFormat('yyyy/MM/dd').format(_startDate);
    }
    if (_endDate != null) {
      _endDateStr = DateFormat('yyyy/MM/dd').format(_endDate);
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
          onPressed: () async {
            await showDatePicker(
              context: context,
              firstDate: _defaultStartDate,
              lastDate: _defaultEndDate,
              initialDate: widget.type == DateSelectorType.start
                  ? widget.initialStartDate ?? _startDate ?? _defaultStartDate
                  : widget.type == DateSelectorType.end
                      ? widget.initialEndDate ?? _endDate ?? _defaultEndDate
                      : DateTime.now(),
            ).then((date) {
              if (date != null) {
                setState(() {
                  if (widget.type == DateSelectorType.start &&
                      _validateStartEndDateRange(date)) {
                    _startDate = date;
                    _startDateStr = DateFormat('yyyy/MM/dd').format(date);

                    if (widget.valSetStartDate != null) {
                      print('1');
                      widget.valSetStartDate(_startDate);
                    }
                  } else if (widget.type == DateSelectorType.end &&
                      _validateStartEndDateRange(date)) {
                    _endDate = date;
                    _endDateStr = DateFormat('yyyy/MM/dd').format(date);

                    if (widget.valSetEndDate != null) {
                      print('2');
                      widget.valSetEndDate(_endDate);
                    }
                  }

                  if (widget.valSetValidDate != null) {
                    widget.valSetValidDate(_validateDate());
                  }
                });
              }
            });
          },
          child: Container(
            alignment: Alignment.center,
            height: _buttonHeight,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today,
                  size: 20.0,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 10.0),
                Text(
                  widget.type == DateSelectorType.start
                      ? _startDateStr ?? 'Start date'
                      : widget.type == DateSelectorType.end
                          ? _endDateStr ?? 'End date'
                          : 'Not set',
                  style: (widget.type == DateSelectorType.start &&
                              _startDateStr != null) ||
                          (widget.type == DateSelectorType.end &&
                              _endDateStr != null)
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
