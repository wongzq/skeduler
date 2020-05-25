import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/shared/widgets/edit_time_dialog.dart';

class AxisTime extends StatefulWidget {
  final ValueSetter<List<Time>> valSetTimes;
  final ValueGetter<List<Time>> valGetTimes;
  final List<Time> initialTimes;
  final bool initiallyExpanded;

  const AxisTime({
    Key key,
    this.valSetTimes,
    this.valGetTimes,
    this.initialTimes,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _AxisTimeState createState() => _AxisTimeState();
}

class _AxisTimeState extends State<AxisTime> {
  OriginTheme _originTheme;
  TimetableStatus _ttbStatus;
  GroupStatus _groupStatus;

  List<Time> _times;

  bool _expanded;

  List<Widget> _generateTimetableTimes() {
    List<Widget> timeslotWidgets = [];

    _times.forEach((time) {
      timeslotWidgets.add(
        ListTile(
          dense: true,
          title: Row(
            children: <Widget>[
              // Time slot start
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: _originTheme.primaryColorLight,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Text(
                  DateFormat('hh:mm aa').format(time.startTime),
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              // to
              Container(
                padding: EdgeInsets.all(10.0),
                child: Text('to'),
              ),

              // Time slot end
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: _originTheme.primaryColorLight,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Text(
                  DateFormat('hh:mm aa').format(time.endTime),
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),

          // Options
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.edit),
                      SizedBox(width: 10.0),
                      Text('Edit'),
                    ],
                  ),
                  value: AvailabilityOption.edit,
                ),
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete),
                      SizedBox(width: 10.0),
                      Text('Remove'),
                    ],
                  ),
                  value: AvailabilityOption.remove,
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case AvailabilityOption.edit:
                  await showDialog(
                    context: context,
                    builder: (context) {
                      DateTime newStartTime = time.startTime;
                      DateTime newEndTime = time.endTime;

                      return EditTimeDialog(
                        contentText: 'Edit schedule time',
                        initialStartTime: time.startTime,
                        initialEndTime: time.endTime,
                        valSetStartTime: (dateTime) => newStartTime = dateTime,
                        valSetEndTime: (dateTime) => newEndTime = dateTime,
                        onSave: () {
                          setState(() {
                            List<Time> tempTimes = List<Time>.from(_times);
                            tempTimes.removeWhere((test) {
                              return test.startTime == time.startTime &&
                                  test.endTime == time.endTime;
                            });
                            tempTimes.add(Time(
                                startTime: newStartTime, endTime: newEndTime));

                            // If no conflict in temporary, then edit in main
                            if (isConsecutiveTimes(tempTimes)) {
                              // Remove previous time slot
                              _times.removeWhere((test) {
                                return test.startTime == time.startTime &&
                                    test.endTime == time.endTime;
                              });

                              // Add new time slot
                              Time prev = Time(
                                  startTime: time.startTime,
                                  endTime: time.endTime);
                              Time next = Time(
                                  startTime: newStartTime, endTime: newEndTime);

                              _ttbStatus.updateTempAxisTimeValue(
                                prev: prev,
                                next: next,
                                members: _groupStatus.members,
                              );

                              _times.add(next);
                              _times.sort((a, b) =>
                                  a.startTime.millisecondsSinceEpoch.compareTo(
                                      b.startTime.millisecondsSinceEpoch));
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'There was a conflict in the time');
                            }

                            // Update through valueSetter
                            if (widget.valSetTimes != null) {
                              widget.valSetTimes(_times);
                            }
                          });
                        },
                      );
                    },
                  );
                  break;

                case AvailabilityOption.remove:
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Remove this time slot?\n\n',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: DateFormat('hh:mm aa')
                                        .format(time.startTime) +
                                    ' to ' +
                                    DateFormat('hh:mm aa').format(time.endTime),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('CANCEL'),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          FlatButton(
                              child: Text(
                                'REMOVE',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  // Remove time slot
                                  _times.removeWhere((test) {
                                    return test.startTime == time.startTime &&
                                        test.endTime == time.endTime;
                                  });

                                  // Update through valueSetter
                                  if (widget.valSetTimes != null) {
                                    widget.valSetTimes(_times);
                                  }
                                });

                                Navigator.of(context).maybePop();
                              }),
                        ],
                      );
                    },
                  );
                  break;
              }
            },
          ),
        ),
      );
    });

    timeslotWidgets.add(_generateAddTimeButton());

    return timeslotWidgets;
  }

  Widget _generateAddTimeButton() {
    return ListTile(
      title: Icon(
        Icons.add_circle,
        size: 30.0,
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) {
          DateTime newStartTime;
          DateTime newEndTime;

          return EditTimeDialog(
            contentText: 'Add time slot',
            valSetStartTime: (dateTime) => newStartTime = dateTime,
            valSetEndTime: (dateTime) => newEndTime = dateTime,
            onSave: () {
              setState(() {
                if (newEndTime.isAfter(newStartTime)) {
                  List<Time> tempTimes = List<Time>.from(_times);
                  tempTimes
                      .add(Time(startTime: newStartTime, endTime: newEndTime));

                  // If no conflict in temporary, then add to main
                  if (isConsecutiveTimes(tempTimes)) {
                    _times.add(
                        Time(startTime: newStartTime, endTime: newEndTime));

                    _times.sort((a, b) => a.startTime.millisecondsSinceEpoch
                        .compareTo(b.startTime.millisecondsSinceEpoch));
                  } else {
                    Fluttertoast.showToast(
                        msg: 'There was a conflict in the time');
                  }

                  if (widget.valSetTimes != null) {
                    widget.valSetTimes(_times);
                  }
                }
              });
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    _expanded = widget.initiallyExpanded;
    _times = widget.initialTimes ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _originTheme = Provider.of<OriginTheme>(context);
    _ttbStatus = Provider.of<TimetableStatus>(context);
    _groupStatus = Provider.of<GroupStatus>(context);

    if (widget.valGetTimes != null) {
      _times = widget.valGetTimes();
    }

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
