import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/shared/functions.dart';

class AxisDay extends StatefulWidget {
  final ValueSetter<List<Weekday>> valSetWeekdaysSelected;
  final List<Weekday> initialWeekdaysSelected;
  final bool initiallyExpanded;

  const AxisDay({
    Key key,
    this.valSetWeekdaysSelected,
    this.initialWeekdaysSelected,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _AxisDayState createState() => _AxisDayState();
}

class _AxisDayState extends State<AxisDay> {
  bool _expanded;

  List<Weekday> _weekdaysSelected;

  List<Weekday> _weekdays = [
    Weekday.mon,
    Weekday.tue,
    Weekday.wed,
    Weekday.thu,
    Weekday.fri,
    Weekday.sat,
    Weekday.sun,
  ];

  List<Widget> _generateTimetableDays() {
    List<Widget> weekdayOptionWidgets = [];

    _weekdays.forEach((weekdayOption) {
      weekdayOptionWidgets.add(ListTile(
        dense: true,

        // Checkbox
        leading: Checkbox(
          activeColor: getFABIconBackgroundColor(context),
          value: _weekdaysSelected.contains(weekdayOption),
          onChanged: (selected) {
            setState(() {
              if (selected == true) {
                // Add to weekdaysSelected
                _weekdaysSelected.add(weekdayOption);
              } else {
                // Remove from weekdaysSelected
                _weekdaysSelected.removeWhere((elem) => elem == weekdayOption);
              }

              // Update through valueSetter
              if (widget.valSetWeekdaysSelected != null) {
                widget.valSetWeekdaysSelected(_weekdaysSelected);
              }
            });
          },
        ),

        // Weekday display
        title: Text(getWeekdayStr(weekdayOption)),
      ));
    });

    return weekdayOptionWidgets;
  }

  @override
  void initState() {
    _expanded = widget.initiallyExpanded;
    _weekdaysSelected = widget.initialWeekdaysSelected ?? [];
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
