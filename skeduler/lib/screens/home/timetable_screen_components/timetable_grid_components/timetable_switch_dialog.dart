import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/timetable.dart';

class TimetableSwitchDialog extends StatefulWidget {
  final TimetableAxes initialAxes;
  final ValueSetter<TimetableAxes> valSetTtbAxes;

  const TimetableSwitchDialog({
    Key key,
    @required this.initialAxes,
    this.valSetTtbAxes,
  }) : super(key: key);

  @override
  _TimetableSwitchDialogState createState() => _TimetableSwitchDialogState();
}

class _TimetableSwitchDialogState extends State<TimetableSwitchDialog> {
  TimetableAxes _newAxes;

  @override
  void initState() {
    _newAxes = widget.initialAxes ?? TimetableAxes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Timetable Axes',
        style: TextStyle(fontSize: 16.0),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        FlatButton(
          child: Text('SAVE'),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }
}
