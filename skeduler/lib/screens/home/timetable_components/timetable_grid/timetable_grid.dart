import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_headers.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_slots.dart';

class TimetableGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    TimetableEditMode editMode = Provider.of<TimetableEditMode>(context);

    TimetableAxes axes =
        editMode.editing ? ttbStatus.editAxes : ttbStatus.currAxes;

    return axes == null || axes.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimetableHeaderX(axisX: axes.xListStr),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TimetableHeaderYZ(
                            axisY: axes.yListStr,
                            axisZ: axes.zListStr,
                          ),
                          TimetableSlots(
                            xType: axes.xDataAxis,
                            yType: axes.yDataAxis,
                            zType: axes.zDataAxis,
                            xList: axes.xList,
                            yList: axes.yList,
                            zList: axes.zList,
                            xListStr: axes.xListStr,
                            yListStr: axes.yListStr,
                            zListStr: axes.zListStr,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}