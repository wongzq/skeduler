import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_headers.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_slots.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableGrid extends StatefulWidget {
  @override
  _TimetableGridState createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  int _groupSelected = 0;

  Widget _generateTimetableGroups(BuildContext context) {
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    OriginTheme originTheme = Provider.of<OriginTheme>(context);

    List<Widget> widgets = [];
    List<List<Weekday>> groups = [
      [Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu],
      [Weekday.fri],
      [Weekday.sat, Weekday.sun]
    ];

    int length = groups.reduce((value, element) => value + element).length;
    double size = MediaQuery.of(context).size.width / length;
    double height = size;

    for (int i = 0; i < groups.length; i++) {
      widgets.add(Container(
          width: size * groups[i].length,
          height: height,
          child: FlatButton(
              color: _groupSelected == i
                  ? originTheme.primaryColor
                  : Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(height / 2),
                      bottomRight: Radius.circular(height / 2))),
              onPressed: () => setState(() => _groupSelected = i),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: groups[i]
                      .map((e) => Text(getWeekdayShortStr(e),
                          style: textStyleBody.copyWith(
                              color: _groupSelected == i
                                  ? originTheme.textColor
                                  : Colors.grey)))
                      .toList()))));
    }

    return Container(height: height, child: Row(children: widgets));
  }

  @override
  Widget build(BuildContext context) {
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    TimetableEditMode editMode = Provider.of<TimetableEditMode>(context);

    TimetableAxes axes =
        editMode.editing ? ttbStatus.editAxes : ttbStatus.currAxes;

    return axes == null
        ? Container()
        : Column(children: [
            _generateTimetableGroups(context),
            Expanded(
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TimetableHeaderX(axisX: axes.xListStr),
                          Expanded(
                              child: Column(children: <Widget>[
                            Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                  TimetableHeaderYZ(
                                      axisY: axes.yListStr,
                                      axisZ: axes.zListStr),
                                  TimetableSlots(
                                      xType: axes.xDataAxis,
                                      yType: axes.yDataAxis,
                                      zType: axes.zDataAxis,
                                      xList: axes.xList,
                                      yList: axes.yList,
                                      zList: axes.zList,
                                      xListStr: axes.xListStr,
                                      yListStr: axes.yListStr,
                                      zListStr: axes.zListStr)
                                ]))
                          ]))
                        ])))
          ]);
  }
}
