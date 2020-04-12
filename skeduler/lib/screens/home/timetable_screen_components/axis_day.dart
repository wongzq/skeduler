import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/shared/functions.dart';

class AxisDay extends StatefulWidget {
  final ValueSetter<List<bool>> valSetTimetableDaysSelected;

  const AxisDay({Key key, this.valSetTimetableDaysSelected}) : super(key: key);

  @override
  _AxisDayState createState() => _AxisDayState();
}

class _AxisDayState extends State<AxisDay> {
  List<bool> _timetableDaysSelected = List.generate(7, (index) => false);
  List<Weekday> _timetableDays = [
    Weekday.mon,
    Weekday.tue,
    Weekday.wed,
    Weekday.thu,
    Weekday.fri,
    Weekday.sat,
    Weekday.sun,
  ];

  List<Widget> _generateTimetableDays() {
    List<Widget> weekdayOptions = [];

    _timetableDays.forEach((weekday) {
      weekdayOptions.add(ListTile(
        dense: true,
        leading: Checkbox(
          activeColor: getFABIconBackgroundColor(context),
          value: _timetableDaysSelected[weekday.index],
          onChanged: (selected) {
            setState(() => _timetableDaysSelected[weekday.index] = selected);
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
      children: _generateTimetableDays(),
    );
  }
}
