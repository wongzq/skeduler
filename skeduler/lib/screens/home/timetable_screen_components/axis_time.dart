import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/shared/components/edit_time_dialog.dart';

class AxisTime extends StatefulWidget {
  final ValueSetter<List<bool>> valSetTimetableTimes;
  final bool initiallyExpanded;

  const AxisTime({
    Key key,
    this.valSetTimetableTimes,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _AxisTimeState createState() => _AxisTimeState();
}

class _AxisTimeState extends State<AxisTime> {
  List<Time> _timetableTimes = [];

  bool _expanded;

  List<Widget> _generateTimetableTimes() {
    List<Widget> timeslots = [];

    timeslots.add(_generateAddTimeButton());

    return timeslots;
  }

  Widget _generateAddTimeButton() {
    return ListTile(
      title: Icon(
        Icons.add_circle,
        size: 30.0,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return EditTimeDialog(
              contentText: 'Add time slot',
              onSave: () {},
            );
          },
        );
      },
    );
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
        'Axis 2 : Time',
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
      children: _generateTimetableTimes(),
    );
  }
}
