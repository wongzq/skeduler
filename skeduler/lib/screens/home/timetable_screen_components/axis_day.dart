import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/shared/functions.dart';

class AxisDay extends StatefulWidget {
  final ValueSetter<List<bool>> valSetTimetableWeekdaysSelected;

  const AxisDay({Key key, this.valSetTimetableWeekdaysSelected})
      : super(key: key);

  @override
  _AxisDayState createState() => _AxisDayState();
}

class _AxisDayState extends State<AxisDay> {
  List<bool> _timetableWeekdaysSelected = List.generate(7, (index) => false);
  List<Weekday> _timetableWeekdays = [
    Weekday.mon,
    Weekday.tue,
    Weekday.wed,
    Weekday.thu,
    Weekday.fri,
    Weekday.sat,
    Weekday.sun,
  ];

  List<Widget> _generateTimetableWeekdays() {
    List<Widget> weekdayOptions = [];

    _timetableWeekdays.forEach((weekday) {
      weekdayOptions.add(ListTile(
        dense: true,
        leading: Checkbox(
          activeColor: getFABIconBackgroundColor(context),
          value: _timetableWeekdaysSelected[weekday.index],
          onChanged: (selected) {
            setState(
                () => _timetableWeekdaysSelected[weekday.index] = selected);
          },
        ),
        title: Text(getWeekdayStr(weekday)),
      ));
    });

    return weekdayOptions;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Axis 1 : Day'),
      children: _generateTimetableWeekdays(),
    );
  }
}
