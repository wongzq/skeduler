import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/auxiliary/time.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_grid_box.dart';

class TimetableSlots extends StatefulWidget {
  final DataAxis xType;
  final DataAxis yType;
  final DataAxis zType;

  final List xList;
  final List yList;
  final List zList;

  final List<String> xListStr;
  final List<String> yListStr;
  final List<String> zListStr;

  const TimetableSlots({
    Key key,
    @required this.xType,
    @required this.yType,
    @required this.zType,
    @required this.xList,
    @required this.yList,
    @required this.zList,
    @required this.xListStr,
    @required this.yListStr,
    @required this.zListStr,
  }) : super(key: key);

  @override
  _TimetableSlotsState createState() => _TimetableSlotsState();
}

class _TimetableSlotsState extends State<TimetableSlots> {
  ScrollController horiScroll;
  List<ScrollController> vertScrolls;

  @override
  Widget build(BuildContext context) {
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    TimetableEditMode editMode = Provider.of<TimetableEditMode>(context);

    horiScroll = horiScroll ??
        (editMode.editing
            ? ttbStatus.editScroll.hori.addAndGet()
            : ttbStatus.currScroll.hori.addAndGet());

    vertScrolls = vertScrolls ??
        List.generate(
            widget.xList.length,
            (_) => editMode.editing
                ? ttbStatus.editScroll.vert.addAndGet()
                : ttbStatus.currScroll.vert.addAndGet());

    return Expanded(
      child: SingleChildScrollView(
        controller: horiScroll,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: () {
            List<Widget> cols = [];

            for (int x = 0; x < widget.xListStr.length; x++) {
              List<Widget> rows = [];

              for (int y = 0; y < widget.yListStr.length; y++) {
                for (int z = 0; z < widget.zListStr.length; z++) {
                  dynamic getAxisVal(DataAxis axisType) => widget.xType ==
                          axisType
                      ? widget.xList[x]
                      : widget.yType == axisType
                          ? widget.yList[y]
                          : widget.zType == axisType ? widget.zList[z] : null;

                  Weekday dayVal = getAxisVal(DataAxis.day);
                  Time timeVal = getAxisVal(DataAxis.time);
                  String customVal = getAxisVal(DataAxis.custom);

                  rows.add(TimetableGridBox(
                    gridBoxType: GridBoxType.content,
                    heightRatio: 1,
                    widthRatio: 1,
                    coord: TimetableCoord(
                      day: dayVal,
                      time: timeVal,
                      custom: customVal,
                    ),
                  ));
                }
              }

              ScrollController vertScroll;

              if (x >= vertScrolls.length || vertScrolls[x] == null) {
                vertScroll = editMode.editing
                    ? ttbStatus.editScroll.vert.addAndGet()
                    : ttbStatus.currScroll.vert.addAndGet();
                vertScrolls.add(vertScroll);
              } else {
                vertScroll = vertScrolls[x];
              }

              cols.add(
                SingleChildScrollView(
                  controller: vertScroll,
                  scrollDirection: Axis.vertical,
                  child: Column(children: rows),
                ),
              );
            }

            return cols;
          }(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
