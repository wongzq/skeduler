import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/shared/functions.dart';

class AxisDay extends StatefulWidget {
  final ValueSetter<List<bool>> valSetTimetableDaysSelected;
  final bool initiallyExpanded;

  const AxisDay({
    Key key,
    this.valSetTimetableDaysSelected,
    this.initiallyExpanded = false,
  }) : super(key: key);

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

  bool _expanded;

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
  void initState() {
    _expanded = widget.initiallyExpanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      onExpansionChanged: (expanded) => setState(() => _expanded = !_expanded),
      initiallyExpanded: widget.initiallyExpanded,
      title: Text(
        'Axis 1 : Day',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
        ),
      ),
      trailing: Icon(
        _expanded ? Icons.expand_less : Icons.expand_more,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      ),
      children: _generateTimetableDays(),
    );
  }
}
