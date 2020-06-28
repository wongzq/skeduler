import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_headers.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_slots.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableGrid extends StatefulWidget {
  @override
  _TimetableGridState createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  int _groupSelected;

  TimetableStatus _ttbStatus;
  TimetableEditMode _editMode;
  OriginTheme _originTheme;

  Widget _generateTimetableGroups(BuildContext context) {
    List<Widget> widgets = [];
    List<TimetableGroup> groups =
        _editMode.editing ? _ttbStatus.edit.groups : _ttbStatus.curr.groups;

    double width = MediaQuery.of(context).size.width / groups.length;
    double height = 40;

    if (groups.length > 1) {
      for (int i = 0; i < groups.length; i++) {
        widgets.add(Container(
            width: width,
            height: height,
            child: FlatButton(
                splashColor: Theme.of(context).primaryColor,
                highlightColor: Theme.of(context).primaryColor,
                color: _groupSelected == i
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(height / 2),
                        bottomRight: Radius.circular(height / 2))),
                onPressed: () => setState(() {
                      if (_editMode.editing) {
                        _ttbStatus.editGroupIndex = i;
                      } else {
                        _ttbStatus.currGroupIndex = i;
                      }
                      _ttbStatus.update();
                    }),
                child: Text((i + 1).toString(),
                    style: textStyleBody.copyWith(
                        color: _groupSelected == i
                            ? Theme.of(context).brightness == Brightness.light
                                ? _originTheme.textColor
                                : Colors.white
                            : Colors.grey)))));
      }
    }

    return widgets.isEmpty
        ? Container()
        : Container(height: height, child: Row(children: widgets));
  }

  @override
  Widget build(BuildContext context) {
    _originTheme = Provider.of<OriginTheme>(context);
    _ttbStatus = Provider.of<TimetableStatus>(context);
    _editMode = Provider.of<TimetableEditMode>(context);

    _groupSelected = _editMode.editing
        ? _ttbStatus.editGroupIndex ?? 0
        : _ttbStatus.currGroupIndex ?? 0;

    TimetableAxes axes =
        _editMode.editing ? _ttbStatus.editAxes : _ttbStatus.currAxes;

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
