import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/shared/functions.dart';

class AxisTime extends StatefulWidget {
  final ValueSetter<List<bool>> valSetTimetableTimes;

  const AxisTime({Key key, this.valSetTimetableTimes}) : super(key: key);

  @override
  _AxisTimeState createState() => _AxisTimeState();
}

class _AxisTimeState extends State<AxisTime> {
  List<Time> _timetableTimes = [];

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
            return AlertDialog();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Axis 2 : Times'),
      children: _generateTimetableTimes(),
    );
  }
}
